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

  step :set_budget_associations!

  # below step persists the model
  step Contract::Persist()

  def set_budget_associations!(options, params:, model:, current_user:, **)
    budget_group = BudgetGroup.find(params&.dig("budget_group_criterion", "budget_group_id"))
    budget_association_data = params&.dig("budget_group_criterion", "budget_group")
    if budget_group.present? and budget_association_data.present?
      budget_group.update_columns(
        invoice: budget_association_data["invoice"] || false,
        purchase_order: budget_association_data["purchase_order"] || false,
        purchase_request: budget_association_data["purchase_request"] || false,
        payment: budget_association_data["payment"] || false,
        expense: budget_association_data["expense"] || false,
      )
    end
    true
  end

  def set_parent_criterium!(options, params:, model:, current_user:, **)
    budget_criterium = model
    parent_criterium = current_user.company.budget_group_criteria.find_by(id: params&.dig("budget_group_criterion", "ancestry"))

    budget_criterium.ancestry = parent_criterium&.id
    budget_criterium.budget_creation_in_progress = true
    true
  end

end