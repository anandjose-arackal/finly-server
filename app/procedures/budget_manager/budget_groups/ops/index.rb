class BudgetManager::BudgetGroups::Ops::Index < Transactions::API

  include HasScope

  has_scope :with_period_id
  has_scope :filter_search
  has_scope :filter_month
  has_scope :filter_year

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now since there's nothing to do here except just return a bunch of indexes, we are going to
  # simply return all budget groups that belong to a particular company
  step :index!

  def index!(options, current_user:, params:, **)
    options["budget_groups"] = current_user.company.budget_groups.active
    scoped_budgets = apply_scopes(options["budget_groups"], params)
    page = params[:page] || 1
    per_page = params[:per_page] || 30
    options["budget_groups"] = scoped_budgets.paginate(page: page, per_page: per_page)
  end
end