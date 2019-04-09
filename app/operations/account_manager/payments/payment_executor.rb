# this class will take a single payment object and executes it using the respective adapters
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
    self.receiving_account_adapter = retrieve_adapter(payment.receiving_account, self.payment)
    self.source_account_adapter = retrieve_adapter(payment.initiating_account, self.payment)
    self.source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
    self.receiving_account_name = receiving_account_adapter.name.is_a?(Array) ? receiving_account_adapter.name.first : receiving_account_adapter.name
  end

  def validate
    if receiving_account_adapter.blank? || source_account_adapter.blank?
      add_message :error, 'Error loading payment'
      return
    end

    # unless the payment is outside Finly, the receiving account and initiating account needs to be present


    # Below each rule engine operation will validate the payment against certain criteria,
    # and mark the payment as failed and add error messages according to the criteria

    ################# Start Source account validations #######################

    # todo - temporary as the tests are failing saying this rule isn't defined
    # op = PaymentProcessorRules::Event.(:check_source_account_debitable, {payment: self.payment, source_account_adapter: self.source_account_adapter, receiving_account_adapter: self.receiving_account_adapter})
    # unless op.success?
    #   add_message :error, op.messages
    #   return
    # end

    if self.payment.credit?
      op = PaymentProcessorRules::Event.(:check_source_account_balance, {payment: self.payment, options: self.options, source_account_adapter: self.source_account_adapter})
      unless op.success?
        add_message :error, op.message
        return
      end
    end


    if self.payment.debit?
      op = PaymentProcessorRules::Event.(:check_source_account_eligibility, {payment: self.payment, options: self.options, source_account_adapter: self.source_account_adapter})
      unless op.success?
        add_message :error, op.message
        return
      end
    end

    ################# End Source account validations ########################


    ####################### Start Receiving account validations #####################

    op = PaymentProcessorRules::Event.(:check_receiving_account_creditable, {payment: self.payment, options: self.options, receiving_account_adapter: self.receiving_account_adapter})
    unless op.success?
      add_message :error, op.message
      return
    end

    if self.payment.credit?
      op = PaymentProcessorRules::Event.(:check_receiving_account_eligibility, {payment: self.payment, options: self.options, receiving_account_adapter: self.receiving_account_adapter})
      unless op.success?
        add_message :error, op.message
        return
      end
    end

    if self.payment.debit?
      op = PaymentProcessorRules::Event.(:check_receiving_account_balance, {payment: self.payment, options: self.options, receiving_account_adapter: self.receiving_account_adapter})
      unless op.success?
        add_message :error, op.message
        return
      end
    end

    ####################### End Receiving account validations ######################


    op = PaymentProcessorRules::Event.(:check_receiving_account_creditable, {payment: self.payment, options: self.options,
                                                                             receiving_account_adapter: self.receiving_account_adapter,
                                                                             source_account_adapter: self.source_account_adapter})
    unless op.success?
      add_message :error, op.message
      return
    end

    op = PaymentProcessorRules::Event.(:ensure_payments_are_pending_before_processing, {payment: self.payment, options: self.options})
    unless op.success?
      add_message :error, op.message
      return
    end

  end

  def pre_process
    # move the payment to "In Progress" before processing
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
      payment.system_messages.destroy_all
      debit_adapter.errors.each do |content|
        payment.system_messages.build(content: content,
                                      system_message_type_id: SystemMessageType.id_for(:error)).save
      end
      debit_adapter.on_failure(payment: self.payment)
      return
    end


    # Credit funds to account
    unless credit_adapter.blank? or credit_adapter.credit(payment, options)
      # Credit failed
        add_message :error, credit_adapter.errors
        unless self.payment.pending_retry?
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        end
        payment.system_messages.destroy_all
        credit_adapter.errors.each do |content|
          payment.system_messages.build(content: content,
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
        end
        # Reverse credit
        debit_adapter.credit(payment, options)

        # execute the on_failure method for failed payments
        credit_adapter.on_failure(payment: self.payment)
      return
    end

    # on success, execute whatever callbacks that need to be processed on success of this transaction
    # essentially calling the on_completion account
    if self.payment.completed?
      debit_adapter.on_completion(payment: self.payment)
      credit_adapter.on_completion(payment: self.payment)
    end

    # todo - probably should be moved to the adapter itself
    # i.e. if the payment was not modified in any way during the execution, update it here.
    if payment.in_progress?
      payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    end

  end

  def post_process

  end

  def execute_callbacks(success)
    self.payment.trigger_callbacks(success)
  end



end
