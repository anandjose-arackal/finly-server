# this would create a payment reque

class Collect::VirtualAccount::Accept < Collect::VirtualAccount::Base

  attr_accessor :virtual_account, :company

  def init
    self.virtual_account = virtual_account_transaction.virtual_bank_account
    self.company = virtual_account.company
    self.payment_request = init_payment_request(:virtual_bank_account)
  end

  def process

  end
end