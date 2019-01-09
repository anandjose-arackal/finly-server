class BudgetsController < ApplicationController
  before_action -> { finly_authorize! :web }
  def index
    @result = Budgets::Index.(current_user, params)
    respond
  end

  def show
    @result = Budgets::Show.(current_user, params)
    respond
  end

  def create
    @result = Budgets::Create.(current_user, params)
    respond
  end

  def update
    @result = Budgets::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Budgets::Destroy.(current_user, params)
    respond
  end

  def configuration
    @result = Budget::Configuration.(current_user, params)
    respond
  end

  def add_budget
    @result = Budgets::Edit::AddBudget.(current_user, params)
    respond_success_failure
  end

  def reduce_budget
    @result = Budgets::Edit::ReduceBudget.(current_user, params)
    respond_success_failure
  end

  def trails
    @result = Budgets::ModificationTrails.(current_user, params)
    respond
  end

  def new_budgets_config
    @result = Budgets::NewBudgetsConfig.(current_user, params)
    respond
  end

  def sample_import_file
    @result = Budgets::GenerateSampleFile.(current_user, params)
    respond
  end

  def import
    @result = Budgets::Import.(current_user, params)
    respond
  end
end