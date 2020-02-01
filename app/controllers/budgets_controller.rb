class BudgetsController < BaseControllers::WebBase

  layout 'trailblazers', only: [:index, :show, :sub_budgets, :create, :update]

  def index
    endpoint BudgetManager::BudgetsTrb::Ops::Index
    # @result = BudgetManager::BudgetsTrb::Ops::Index.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::Index.(current_user, params)
    # respond
  end

  def show
    endpoint BudgetManager::BudgetsTrb::Ops::Show
    # @result = BudgetManager::BudgetsTrb::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::Show.(current_user, params)
    # respond
  end

  def show_trail_items
    @result = Budgets::ShowTrailItems.(current_user, params)
    respond
  end

  def sub_budgets
    endpoint BudgetManager::BudgetsTrb::Ops::Show
    # @result = BudgetManager::BudgetsTrb::Ops::Show.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::SubBudgets.(current_user, params)
    # respond
  end

  def create
    endpoint BudgetManager::BudgetsTrb::Ops::Create
    # @result = BudgetManager::BudgetsTrb::Ops::Create.(params.to_unsafe_h, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::Create.(current_user, params)
    # respond
  end

  def update
    endpoint BudgetManager::BudgetsTrb::Ops::Create
    # @result = BudgetManager::BudgetsTrb::Ops::Update.(params, "current_user" => current_user)
    respond_to do |format|
      format.json {}
    end
    # @result = Budgets::Update.(current_user, params)
    # respond
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