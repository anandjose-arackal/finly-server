class BudgetManager::BudgetGroupCriteria::Ops::Index < Transactions::API

  include HasScope

  has_scope :filter_search

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  step Model(BudgetGroup, :find)

  step :index!

  def index!(options, current_user:, params:, **)
    budget_group = options["model"]
    if params[:include_children]
      options["budget_group_criteria"] = budget_group.budget_group_criteria.include_for_index
    else
      options["budget_group_criteria"] = budget_group.budget_group_criteria.roots.include_for_index
    end
    options["budget_group_criteria"] = apply_scopes(options["budget_group_criteria"], params)
  end
end