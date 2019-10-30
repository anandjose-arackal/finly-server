class BudgetGroupsController < BaseControllers::WebBase

  def create
    @result = BudgetGroups::Create.(params, "current_user" => current_user)
    respond
  end
end