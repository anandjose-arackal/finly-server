# this class will take a single payment object and executes it using the respective adapters
#
class AccountManager::Payments::PaymentExecutor < AccountManager::Base

  attr_accessor :payment, :payment_item, :receiving_account_adapter, :source_account_adapter, :options,
                :source_account_name, :receiving_account_name

  def self.call(payment, options = {})
    self.new(payment, options).run
  end

  def self.call_async(payment_id)
    # define the operation to accordingly run the operation in the background
    payment = Payment.find_by(id: payment_id)
    self.new(payment).run
  end

  def initialize(payment, options = {})
    self.payment = payment
    self.options = options
  end

  def init
    self.receiving_account_adapter = retrieve_adapter(payment.receiving_account)
    self.source_account_adapter = retrieve_adapter(payment.initiating_account)
    self.source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
    self.receiving_account_name = receiving_account_adapter.name.is_a?(Array) ? receiving_account_adapter.name.first : receiving_account_adapter.name
  end

  def validate
    unless receiving_account_adapter.present?
      add_message :error, 'Error loading payment'
      return
    end
    unless receiving_account_adapter.creditable_account?(payment.initiating_account)
      add_message :error, 'You cannot credit from this account'
      payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                    content: "You cannot credit from #{source_account_name} to #{receiving_account_name}").save
      return
    end

    unless receiving_account_adapter.eligibility(payment.amount_value)
      add_message :error, 'Insufficient eligibility to transfer the funds'
      payment.system_messages.build(content: "This account cannot be credited with #{payment.amount_value} due to lack of eligibility",
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
      return
    end

    if source_account_adapter.present?
      unless source_account_adapter.debitable_account?(payment.receiving_account)
        add_message :error, "You cannot debit to this account"
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "You cannot debit from #{receiving_account_name} to #{source_account_name}").save
        return
      end

      unless source_account_adapter.balance > payment.amount_value
        add_message :error, "This account does not have enough balance for this transaction"
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "Not enough funds in #{payment.source_account_type.to_s} to initiate the transfer").save
        return
      end
    end

    unless [PaymentStatus.id_for(:scheduled), PaymentStatus.id_for(:pending)].include?(payment.payment_status_id)
      add_message :error, "Payment cannot be processed in this state"
      # add system message
    end
  end

  def pre_process
    # update payment to in progress
    payment.update(payment_status_id: PaymentStatus.id_for(:in_progress))
  end

  def process
    debit_adapter = nil
    credit_adapter = nil
    case payment.payment_type_id
      when PaymentType.id_for(:credit)
        debit_adapter = source_account_adapter
        credit_adapter = receiving_account_adapter
      when PaymentType.id_for(:debit)
        credit_adapter = source_account_adapter
        debit_adapter = receiving_account_adapter
      else
        add_message :error, 'Invalid Payment Type'
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        return
    end

    # Debit funds from account
    unless debit_adapter.blank? or debit_adapter.debit(payment, options)
       # Debit failed
      add_message :error, debit_adapter.errors
      payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      debit_adapter.errors.each do |content|
        payment.system_messages.build(content: content,
                                      system_message_type_id: SystemMessageType.id_for(:error)).save
      end
      return
    end

    # Credit funds to account
    unless credit_adapter.blank? or credit_adapter.credit(payment, options)
      # Credit failed
        add_message :error, credit_adapter.errors
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        credit_adapter.errors.each do |content|
          payment.system_messages.build(content: content,
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
        end
        # Reverse credit
        debit_adapter.credit(payment, options)
      return
    end

    # todo - probably should be moved to the adapter itself
    payment.update(payment_status_id: PaymentStatus.id_for(:completed))
  end

  def post_process

  end

  private


end
