class BudgetGroupsController < BaseControllers::WebBase

  layout 'trailblazers'

  def create
    endpoint BudgetManager::BudgetGroups::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint BudgetManager::BudgetGroups::Ops::Update
    respond_to do |format|
      format.json {}
    end
  end

  def index
    endpoint BudgetManager::BudgetGroups::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def show
    endpoint BudgetManager::BudgetGroups::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end

  def destroy
    endpoint BudgetManager::BudgetGroups::Deactivate
    respond_to do |format|
      format.json {}
    end
  end

end