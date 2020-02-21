class BudgetManager::BudgetGroupCriteria::Ops::Index < Transactions::API

  include HasScope

  has_scope :filter_search

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  step Model(BudgetGroup, :find)

  step :index!

  def index!(options, current_user:, params:, **)
    budget_group = options["model"]
    options["budget_group_criteria"] = budget_group.budget_group_criteria.roots
    options["budget_group_criteria"] = apply_scopes(options["budget_group_criteria"], params)
  end
end