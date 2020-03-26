class BudgetManager::BudgetGroups::Ops::Deactivate < Transactions::API
  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now we find the model based on the ID passed from the route
  step Model(BudgetGroup, :find)

  step :deactivate_budget_group!

  def deactivate_budget_group!(options, model:, **)
    model.update(active: false)
    true
  end
end