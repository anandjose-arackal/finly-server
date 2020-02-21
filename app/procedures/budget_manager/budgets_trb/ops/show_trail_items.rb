class BudgetManager::BudgetsTrb::Ops::ShowTrailItems < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now we find the model based on the ID passed from the route
  step Model(Budget, :find)

  # this step will call the BudgetsComputer model and extract the items that are relevant
  # to this particular budget
  step :retrieve_trail_items!


  def retrieve_trail_items!(options, model:, **)
    budget = model
    # calling the budgets computer model that computes the budgets for me
    # TODO - uncomment the below once done
    # op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget})
    # if op.success?
    #   options["result"] = op["result"]
    # end
    true
  end
end