class BudgetManager::BudgetGroups::Ops::Create < Transactions::API


  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # the below step created an instance of BudgetGroup model that can then be populated using the params sent from the FE
  step Model(BudgetGroup, :new)

  # below is the Authorizer - that decides whether a particular user can create a budget group or not (redundant here as )
  # step Policy::Pundit(BudgetManager::BudgetAuthorizer, :create?)

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

  # the below will persist the model and send back errors if any
  step Contract::Persist()

end