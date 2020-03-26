class BudgetManager::BudgetsTrb::Ops::Create < Transactions::API

  attr_accessor :budget_group

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # below step initializes a Budget model that can then be assigned attributes for
  # later populating based on the params sent
  step Model(Budget, :new)

  # below assigns user_id and comapany_id to the budget model based on the current user who is taking the action
  step AssignModelUser(key: :user)

  # this step assigns the defaults of the model that are picked from the params
  # step :set_defaults!

  # calling the contract to assign all the relevant attributes. This step only "assigns" the variables so to speak,
  # but doesn't really do anything yet. That happens in the next step
  step Contract::Build(constant: BudgetManager::BudgetsTrb::Contracts::Base)

  # This step actually performs the validations in the Contract
  step Contract::Validate(key: "budget")

  # this step actually persists the Model
  step Contract::Persist()

end
