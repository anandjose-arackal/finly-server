# this class merely takes the payment order and payment objects and validates whether
# such a payment is possible

class AccountManager::Payments::PaymentValidator < BaseOperation

  attr_accessor :payment_order, :receiving_account_adapter, :initiating_account_adapter

  def initialize(payment_order)
    self.payment_order = payment_order
  end

  def self.call(payment_order)
    self.new(payment_order).run
  end

  def pre_validate

  end

  def init

  end

  def validate
    # this validation is irrespective of the source and destination of the payment
    # i.e. checking for consistency of initiating and receiving accounts etc.

  end

  # here all the validations required for the respective payment order will happen
  def process
    # checking if total order amount is less than the company balance amount

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
      else
        return AccountManager::Company::CompanyBalanceAdapter.new(account_type.id)
    end
  end
end