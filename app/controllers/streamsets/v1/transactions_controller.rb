class Streamsets::V1::TransactionsController < BaseControllers::StreamsetsBase

  def expenses
    @result = Expense::Index.(current_user, params)
    respond
  end

  def invoices
    # @result = BankTransfer::InwardInvoices::Index.(current_user, params)
    @result = Streamsets::Transactions::Invoices.(current_user, params)
    respond
  end

  def payments
    @result = BankTransfer::PaymentRequest::Index.(current_user, params)
    respond
  end

end