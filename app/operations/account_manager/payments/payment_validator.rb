# this class merely takes the payment order and payment objects and validates whether
# such a payment is possible

class AccountManager::Payments::PaymentValidator < AccountManager::Base

  attr_accessor :payment_order, :receiving_account_adapter, :initiating_account_adapter,
                :homogenous_accounts, :source_account_adapter, :receiving_account_adapter,
                :source_account_name, :receiving_account_name, :crediting_payments, :options

  def initialize(payment_order, crediting_payments = [], options = {})
    self.payment_order = payment_order
    self.crediting_payments = crediting_payments
    self.options = options
  end

  def self.call(payment_order, crediting_payments=[], options = {})
    self.new(payment_order, crediting_payments, options).run
  end

  def pre_validate
    if payment_order.blank?
      add_message :error, "Payment Order not passed"
      return
    end
    unless payment_order.valid?
      add_message :error, payment_order.errors.full_messages
      return
    end
  end

  def init
    # at this point the payments are all homogenous, so adapters can be initiated with the first payment's details
    self.source_account_adapter = retrieve_adapter(payment_order.payments.first.initiating_account)
    self.source_account_name = source_account_adapter.name.is_a?(Array) ? source_account_adapter.name.first : source_account_adapter.name
    if self.crediting_payments.blank?
      self.crediting_payments = self.payment_order.payments
    end
  end

  def validate
    # this validation is irrespective of the source and destination of the payment
    # i.e. checking for consistency of initiating and receiving account types etc.
    op = PaymentProcessorRules::Event.(:validate_account_consistency, {crediting_payments: self.crediting_payments})

    # the below has been moved to the PaymentProcessor Rule engine
    unless validate_account_consistency(payment_order, self.crediting_payments)
      add_message :error, "Receiving and initiating accounts must be homogenous"
      return
    end
  end

  # here all the validations required for the respective payment order will happen
  def process
    # # checking for payment oder schedule date
    # if payment_order.scheduled_at and payment_order.scheduled_at < Date.today
    #   add_message :error, "Scheduled date cannot be in the past"
    #   return
    # end

    # checking if total order amount is less than the company balance amount
    if payment_order.credit?
      # checking for the balance in the source account
      op = PaymentProcessorRules::Event.(:check_source_account_balance, {crediting_payments: self.crediting_payments, source_account_adapter: self.source_account_adapter})
      unless op.success?
        add_message :error, op.messages
        return
      end

      # checking for the eligibility of the receiving account
      # this will also incorporate any checks with respect to the eligibility of the
      # receiving account - i.e. limits on maximum for a vendor, or maximum for a bank acocunt etc.
      op = PaymentProcessorRules::Event.(:check_eligibility_of_each_payment, {source_account_adapter: self.source_account_adapter, crediting_payments: self.crediting_payments})
      unless op.success?
        add_message :error, op.messages
        return
      end
      # order_total = payment_order.request_total
      # unless source_account_adapter.balance(payment_order: payment_order, payment_process: self.options[:payment_process])
      #   add_message :error, "Error retrieving the source account's balance. Try again later"
      #   return
      # end
      # if order_total > source_account_adapter.balance(payment_order: payment_order, payment_process: self.options[:payment_process])
      #   add_message :error, "You do not have enough balance in #{source_account_name} to make this transfer"
      #   return
      # end
    end

    # checking if all the users who're being credited have the eligibility
    # only needs to be done if it's a credit
    if payment_order.credit?
      valid = true
      payment_order.payments.each do |payment|
        receiving_account_adapter = retrieve_adapter payment.receiving_account
        unless receiving_account_adapter.eligibility(payment.amount_value)
          valid = false
          # If the object exists, i.e only validator is not being called
          if payment.id.present?
            payment.system_messages.build(content: "This account cannot be credited with #{payment.amount_value}",
                                          system_message_type_id: SystemMessageType.id_for(:error)).save
          end
        end
      end
      unless valid
        add_message :error, 'Some of the payments cannot be processed because of lack of eligibility'
      end
    end

    if payment_order.debit?
      # checking the balance of the receiving account for a debit
      self.receiving_account_adapter = retrieve_adapter payment.receiving_account
      op = PaymentProcessorRules::Event.(:check_receiving_account_balance, {receiving_account_adapter: self.receiving_account_adapter,
                                                                               crediting_payments: self.crediting_payments})

      unless op.success?
        add_message :error, op.messages
        return
      end

      # valid = true
      # payment_order.payments.each do |payment|
      #   receiving_account_adapter = retrieve_adapter payment.receiving_account
      #   unless receiving_account_adapter.balance >= payment.amount_value
      #     valid = false
      #     # If the object exists, i.e only validator is not being called
      #     if payment.id.present?
      #       payment.system_messages.build(content: "#{receiving_account_adapter.name} has insufficient balance",
      #                                     system_message_type_id: SystemMessageType.id_for(:error)).save
      #     end
      #   end
      # end
      # unless valid
      #   add_message :error, "There isn't enough balance in the source account for this transaction"
      # end
    end
  end

  private

  # def validate_account_consistency(payment_order, crediting_payments = [])
  #   self.homogenous_accounts = true
  #   initiating_account_type = payment_order.payments.first.initiating_account_type
  #   receiving_account_type = payment_order.payments.first.receiving_account_type
  #   payments = (crediting_payments.present? && !crediting_payments&.empty?) ? crediting_payments : payment_order.payments
  #   payments.each do |payment|
  #     unless payment.receiving_account_type == receiving_account_type
  #       payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
  #                                     content: 'Receiving account type has to be same for all transfers').save
  #       self.homogenous_accounts = false
  #     end
  #     unless payment.initiating_account_type == initiating_account_type
  #       payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
  #                                     content: 'Initiating account type has to be same for all transfers').save
  #       self.homogenous_accounts = false
  #     end
  #   end
  #   homogenous_accounts
  # end

  # def check_balance
  #
  # end
end