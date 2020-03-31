class BudgetManager::BudgetsTrb::Ops::Show < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now we find the model based on the ID passed from the route
  step Model(Budget, :find)

  step :recalculate_buckets!

  def recalculate_buckets!(options, model:, **)
    budget = model
    # TODO - the below will be removed as the budgets will be updated dynamically
    # if calculate_buckets
      op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
    # end
    return true
  end

end