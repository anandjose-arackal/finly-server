class Dashboards::ExpenseManagementController < BaseControllers::WebBase

  def configs
    @result = Dashboard::ExpenseManagement::Configs.(current_user, params)
    respond
  end

  def expenses
    @result = Dashboard::ExpenseManagement::Expenses.(current_user, params)
    respond
  end

  def reports
    @result = Dashboard::ExpenseManagement::ReportsDashboard.(current_user, params)
    respond
  end

  def money_requests
    @result = Dashboard::ExpenseManagement::MoneyRequestsDashboard.(current_user, params)
    respond
  end

  def trips
    @result = Dashboard::ExpenseManagement::Trips.(current_user, params)
    respond
  end

  def awaiting_action
    @result = Dashboard::ExpenseManagement::AwaitingAction.(current_user, params)
    respond
  end
end
