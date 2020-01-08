class Streamsets::V1::TransactionsController < BaseControllers::StreamsetsBase

  def expenses
    @result = Expense::Index.(current_user, params)
    respond
  end

end