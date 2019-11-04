class BudgetManager::BudgetTrails::Ops::Create < Transactions::API

  # the below step created an instance of BudgetTrail model that can then be populated using the params sent from the FE
  step Model(BudgetTrail, :new)

  # using the standard contract to ensure that the relevant fields are all being populated correctly
  # based on the validations defined in the contract
  step Contract::Build(constant: BudgetManager::BudgetTrails::Contracts::Base)

  # now validating the parameters passed against the contract to run the validations
  step Contract::Validate(key: "budget_trail")

  step Contract::Persist()

end