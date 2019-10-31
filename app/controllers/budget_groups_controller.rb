class BudgetGroupsController < BaseControllers::WebBase

  def create
    @result = BudgetManager::BudgetGroups::Ops::Create.(params, "current_user" => current_user)

  end

  def update

  end
end