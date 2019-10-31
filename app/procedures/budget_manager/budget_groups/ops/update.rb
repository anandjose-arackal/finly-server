class BudgetManager::BudgetGroups::Ops::Update < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # now we find the model based on the ID passed from the route
  step Model(BudgetGroup, :find)

  # the below step adds company_id and created_by_user_id to the budget_group key inside params
  step AssignModelUser(key: :created_by_user)

  # in the below step, we are telling TBZ which contract to use for this particular operation, inside "constant:"
  step Contract::Build(constant: BudgetManager::BudgetGroups::Contracts::Base)

  # in the next step, if the budget group is being sent within a key called 'budget_group' eg.
  # { "budget_group":
  #     {"name":
  #      "period":
  #     }
  # }
  # so here, we have to pass the topmost key so that TBZ knows the key to look for
  step Contract::Validate(key: 'budget_group')

  step Contract::Persist()

end