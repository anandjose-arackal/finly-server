# this class merely takes the payment order and payment objects and validates whether
# such a payment is possible

class AccountManager::Payments::PaymentValidator < BaseOperation

  attr_accessor :payment_order, :receiving_account_adapter, :initiating_account_adapter,
                :errors_present, :card_config

  def initialize(payment_order)
    self.payment_order = payment_order
  end

  def self.call(payment_order)
    self.new(payment_order).run
  end

  def pre_validate
    if payment_order.blank?
      add_message :error, "Payment Order not passed"
    end
    # this validation is irrespective of the source and destination of the payment
    # i.e. checking for consistency of initiating and receiving account types etc.
    unless validate_account_consistency(payment_order)
      add_message :error, "Receiving and initiating accounts must be homogenous"
      return
    end
  end

  def init
    # at this point the payments are all homogenous, so adapters can be initiated with the first payment's details
    self.initiating_account_adapter = retrieve_adapter(payment_order.payments.first.initiating_account)
  end

  def validate

  end

  # here all the validations required for the respective payment order will happen
  def process
    # checking for payment oder schedule date
    if payment_order.scheduled_at < Date.today
      add_message :error, "Scheduled date cannot be in the past!"
      return
    end

    # checking if total order amount is less than the company balance amount
    order_total = payment_order.request_total
    if order_total > initiating_account_adapter.balance
      add_message :error, "You do not have enough balance in #{initiating_account_adapter.name} to make this transfer"
      return
    end

    # checking if all the users who're being credited have the respective cards
    # only needs to be done if it's a credit
    if payment.credit?
      valid = true
      payment_order.payments.each do |payment|
        receiving_account_adapter = retrieve_adapter payment.receiving_account
        unless receiving_account_adapter.eligibility(payment.amount_value)
          valid = false
          payment.system_messages.build(content: "This account cannot be credited with #{payment.amount_value}",
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
        end
      end
      unless valid
        add_message :error, "Some of the payments have eligibility issues"
      end
    end
  end

  private

  def retrieve_adapter(account_type)
    case account_type.class.to_s
      when 1, Card, "Card"
        # Card, for example
        return AccountManager::Cards::CardAdapter.new(account_type.id)
      when 2, UserWallet, "UserWallet"
        # Wallet for example
        return AccountManager::Wallet::WalletAdapter.new(account_type.id)
      when 3, YesBankCompanyAccount, "YesBankCompanyAccount"
        return AccountManager::YesBank::YesBankCompanyAccountAdapter.new(account_type.id)
      else
        return AccountManager::Company::ItzCashCompanyBalanceAdapter.new(account_type.id)
    end
  end

  def validate_account_consistency(payment_order)
    self.errors_present = false
    initiating_account_type = payment_order.payment.first.initiating_account_type
    receiving_account_type = payment_order.payment.first.receiving_account_type
    payment_order.payments.each do |payment|
      unless payment.receiving_account_type == receiving_account_type
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "Receiving account type has to be same for all transfers").save
        self.errors_present = true
      end
      unless payment.initiating_account_type == initiating_account_type
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "Initiating account type has to be same for all transfers").save
        self.errors_present = true
      end
    end
    errors_present
  end

  def check_balance

  end
end