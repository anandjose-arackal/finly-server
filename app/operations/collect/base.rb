class Collect::Base < BackgroundOperation

  attr_accessor :virtual_account_transaction, :options, :virtual_account

  def self.call(virtual_account_transaction_id, options = {})
    self.virtual_account_transaction = VirtualAccountTransaction.find_by(id: virtual_account_transaction_id)
    self.new(virtual_account_transaction, options).run
  end

  def self.call_async(virtual_account_transaction_id, options = {})
    # define the operation to accordingly run the operation in the background
    self.virtual_account_transaction = VirtualAccountTransaction.find_by(id: virtual_account_transaction_id)
    self.new(virtual_account_transaction, options).run
  end

  def initialize(virtual_account_transaction, options = {})
    self.virtual_account_transaction = virtual_account_transaction
    self.options = options
  end

  def init_payment_request(purpose, company)
    # todo - initiating resource to be finished
    initiating_account = self.virtual_account
    initiating_user = nil
    payment_request = PaymentRequest.(initiating_user, initiating_account, company.yes_bank_company_account.class.name, :credit, :virtual_account_credit)
    payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, company.yes_bank_company_account, self.virtual_account_transaction.transfer_amount))
    payment_request
  end

  
end