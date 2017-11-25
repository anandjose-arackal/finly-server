class Collect::VirtualAccount::Base < BaseOperation


  def init_payment_request(purpose, company)
    initiating_account = self.virtual_account
    initiating_user = self.virtual_account.initiating_user
    payment_request = PaymentRequest.(initiating_user, initiating_account, company.yes_bank_company_account.class.name, :credit, :virtual_account_credit)
    payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, company.yes_bank_company_account, self.virtual_account_transaction.transfer_amount))
    payment_request
  end
end