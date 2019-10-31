class BudgetManager::BudgetGroups::Ops::Index < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now since there's nothing to do here except just return a bunch of indexes, we are going to
  # simply return all budget groups that belong to a particular company
  step :index!

  def index!(options, current_user:, **)
    options["budget_groups"] = current_user.company.budget_groups
  end
end