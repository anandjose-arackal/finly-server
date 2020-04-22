class BudgetGroupCriteriaController < BaseControllers::WebBase

  layout 'trailblazers'

  def create
    endpoint BudgetManager::BudgetGroupCriteria::Ops::Create
    # @result = BudgetManager::BudgetGroupCriteria::Ops::Create.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint BudgetManager::BudgetGroupCriteria::Ops::Update
    respond_to do |format|
      format.json {}
    end
  end

  def destroy

  end

  def show
    endpoint BudgetManager::BudgetGroupCriteria::Ops::Show
    # @result = BudgetManager::BudgetGroupCriteria::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def index
    endpoint BudgetManager::BudgetGroupCriteria::Ops::Index
    # @result = BudgetManager::BudgetGroupCriteria::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

end
