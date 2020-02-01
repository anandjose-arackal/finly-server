class BudgetGroupsController < BaseControllers::WebBase

  layout 'trailblazers'

  def create
    endpoint BudgetManager::BudgetGroups::Ops::Create
    # @result = BudgetManager::BudgetGroups::Ops::Create.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint BudgetManager::BudgetGroups::Ops::Update
    # @result = BudgetManager::BudgetGroups::Ops::Update.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def index
    endpoint BudgetManager::BudgetGroups::Ops::Index
    # @result = BudgetManager::BudgetGroups::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def show
    endpoint BudgetManager::BudgetGroups::Ops::Show
    # @result = BudgetManager::BudgetGroups::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
  end


end