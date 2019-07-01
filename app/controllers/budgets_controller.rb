class BudgetsController < BaseControllers::WebBase
  def index
    @result = Budgets::Index.(current_user, params)
    respond
  end

  def show
    @result = Budgets::Show.(current_user, params)
    respond
  end

  def show_trail_items
    @result = Budgets::ShowTrailItems.(current_user, params)
    respond
  end

  def sub_budgets
    @result = Budgets::SubBudgets.(current_user, params)
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

  def bulk_update
    @result = Budgets::BulkUpdate.(current_user, params)
    if @result.success?
      respond
    else
      render file: 'budgets/bulk_update'
    end
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