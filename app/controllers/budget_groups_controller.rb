class BudgetGroupsController < BaseControllers::WebBase

  layout 'trailblazers'

  def create
    @result = BudgetManager::BudgetGroups::Ops::Create.(params, "current_user" => current_user)

  end

  def update

  end

  def index
    @result = BudgetManager::BudgetGroups::Ops::Index.(params, "current_user" => current_user)
    render 'index'
    return
  end

  def show

  end


end