class BudgetsController < BaseControllers::WebBase

  layout 'trailblazers', only: [:index, :show, :sub_budgets, :create, :update]

  def index
    endpoint BudgetManager::BudgetsTrb::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def show
    endpoint BudgetManager::BudgetsTrb::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end


  # TODO - have to move this to TRB
  def show_trail_items
    endpoint BudgetManager::BudgetsTrb::Ops::ShowTrailItems
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::ShowTrailItems.(current_user, params)
    # respond
  end

  def sub_budgets
    endpoint BudgetManager::BudgetsTrb::Ops::Show
    respond_to do |format|
      format.json {}
    end
  end

  def create
    endpoint BudgetManager::BudgetsTrb::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def update
    endpoint BudgetManager::BudgetsTrb::Ops::Update
    respond_to do |format|
      format.json {}
    end
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
    endpoint BudgetManager::BudgetsTrb::Ops::Deactivate
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::Destroy.(current_user, params)
    # respond
  end

  # def configuration
  #   @result = Budget::Configuration.(current_user, params)
  #   respond
  # end

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
    if @result.success?
      respond_to do |format|
        format.json {}
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end

  end

  # deprecated op
  def import
    @result = Budgets::Import.(current_user, params)
    respond
  end

  def process_template_file
    @result = Budgets::ProcessTemplateFile.(current_user, params)
    if @result.success?
      respond
    else
      render file: 'budgets/process_template_file'
    end
  end

end