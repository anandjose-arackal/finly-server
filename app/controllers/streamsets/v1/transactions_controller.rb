class Streamsets::V1::TransactionsController < BaseControllers::StreamsetsBase

  def expenses
    @result = Streamsets::Transactions::Expenses.(current_user, params)
    respond
  end

  def invoices
    @result = Streamsets::Transactions::Invoices.(current_user, params)
    respond
  end

  def payments
    @result = Streamsets::Transactions::Payments.(current_user, params)
    respond
  end

  def statements
    @result = Streamsets::Transactions::Statements.(current_user, params)
    respond
  end

  def vendors
    @result = Streamsets::Transactions::Vendors.(current_user, params)
    respond
  end

end