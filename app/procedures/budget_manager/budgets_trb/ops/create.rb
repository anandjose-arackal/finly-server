class BudgetManager::BudgetsTrb::Create < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # below step initializes a Budget model that can then be assigned attributes for
  # later populating based on the params sent
  step Model(Budget, :new)

  # below assigns user_id and comapany_id to the budget model based on the current user who is taking the action
  step AssignModelUser(key: :user)



end
