class BudgetManager::BudgetsTrb::Ops::Update < Transactions::API

  attr_accessor :budget_group

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # below step initializes a Budget model that can then be assigned attributes for
  # later populating based on the params sent
  step Model(Budget, :find)

  # this step will setup the values for the budget - addition or reduction of the amounts
  step :setup_budget_values!

  # calling the contract to assign all the relevant attributes. This step only "assigns" the variables so to speak,
  # but doesn't really do anything yet. That happens in the next step
  step Contract::Build(constant: BudgetManager::BudgetsTrb::Contracts::Base)

  # This step actually performs the validations in the Contract
  step Contract::Validate(key: "budget")

  # this step actually persists the Model
  step Contract::Persist()

  def setup_budget_values!(options, params:, model:, **)
    type = params.dig("budget", "type")
    change_amount = params.dig("budget", "budget_amount", "value").to_f
    case type
    when "reduce"
      budget_amount = model.budget_amount&.value
      new_budget_amount = budget_amount.to_f - change_amount
      params["budget"]["budget_amount"] = {"value" => new_budget_amount}
    else
      budget_amount = model.budget_amount&.value
      new_budget_amount = budget_amount.to_f + change_amount
      params["budget"]["budget_amount"] = {"value" => new_budget_amount}
    end
    true
  end

end