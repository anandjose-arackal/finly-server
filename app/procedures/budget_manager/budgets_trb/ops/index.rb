class BudgetManager::BudgetsTrb::Ops::Index < Transactions::API

  include HasScope

  has_scope :with_period_id
  has_scope :filter_search
  has_scope :filter_budget_group_id

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now since there's nothing to do here except just return a bunch of indexes, we are going to
  # simply return all budget groups that belong to a particular company
  step :index!

  def index!(options, current_user:, params:, **)
    options["budgets"] = current_user.company.budgets
    options["budgets"] = apply_scopes(options["budgets"], params)
  end
end