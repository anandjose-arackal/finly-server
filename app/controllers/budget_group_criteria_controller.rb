class BudgetGroupCriteriaController < BaseControllers::WebBase

  layout 'trailblazers'

  def create
    @result = BudgetManager::BudgetGroupCriteria::Ops::Create.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update

  end

  def destroy

  end

  def show
    @result = BudgetManager::BudgetGroupCriteria::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def index
    @result = BudgetManager::BudgetGroupCriteria::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

end
