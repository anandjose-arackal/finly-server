class BudgetManager::BudgetGroupCriteria::Ops::Create < Transactions::API

  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # the below step created an instance of BudgetGroupCriterium model that can then be populated using the params sent from the FE
  step Model(BudgetGroupCriterium, :new)

  # the below step adds company_id and created_by_user_id to the budget_group_criterium key inside params
  step AssignModelUser(key: :created_by_user)

  # in the below step, we are telling TBZ which contract to use for this particular operation, inside "constant:"
  step Contract::Build(constant: BudgetManager::BudgetGroupCriteria::Contracts::Base)

  # This step actually performs the validations mentioned in the contract
  step Contract::Validate(key: 'budget_group_criterion')

  step :set_parent_criterium!

  # below step persists the model
  step Contract::Persist()

  def set_parent_criterium!(options, params:, model:, current_user:, **)
    budget_criterium = model
    parent_criterium = current_user.company.budget_group_criteria.find_by(id: params&.dig("budget_group_criterion", "ancestry"))

    budget_criterium.ancestry = parent_criterium&.id
    budget_criterium.budget_creation_in_progress = true
    true
  end

end