# this would create a payment reque

class Collect::VirtualAccount::Accept < Collect::VirtualAccount::Base

  attr_accessor :virtual_account, :company

  def init
    self.virtual_account = self.virtual_account_transaction.virtual_bank_account
    self.company = virtual_account.company
    self.payment_request = init_payment_request(:virtual_bank_account, company)
  end

  def process
    # triggering the operation for creating the payment
    op = AccountManager::Payments::PaymentProcessor.(self.virtual_account.initiating_user, payment_request: self.payment_request)
  end

  def post_process
    # trigger mailers if necessary
  end
end