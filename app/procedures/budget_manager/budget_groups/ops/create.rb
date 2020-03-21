class BudgetManager::BudgetGroups::Ops::Create < Transactions::API


  # the below line accepts a bunch of roles and allows only users with those roles to do this action
  step Transactions::Authorization::Roles(:budget_manager, :admin)

  # the below step created an instance of BudgetGroup model that can then be populated using the params sent from the FE
  step Model(BudgetGroup, :new)

  # below is the Authorizer - that decides whether a particular user can create a budget group or not (redundant here as Authorization class takes care of scoping roles)
  # step Policy::Pundit(BudgetManager::BudgetAuthorizer, :create?)

  # the below step adds company_id and created_by_user_id to the budget_group key inside params
  step AssignModelUser(key: :created_by_user)

  # in the below step, we are telling TBZ which contract to use for this particular operation, inside "constant:"
  step Contract::Build(constant: BudgetManager::BudgetGroups::Contracts::Base)

  # in the next step, the budget group is being sent within a key called 'budget_group' eg.
  # { "budget_group":
  #     {"name":
  #      "period":
  #     }
  # }
  # so here, we have to pass the topmost key so that TBZ knows the key to look for.
  # This step actually performs the validations mentioned in the contract
  step Contract::Validate(key: 'budget_group')

  # the below will persist the model and send back errors if any
  step Contract::Persist()

  step :set_applicable_documents!

  def set_applicable_documents!(options, params:, model:, current_user:, **)
    budget_group = model
    if params&.dig("budget_group", "expense_management")
      budget_group.expense = true
    end
    if params&.dig("budget_group", "vendor_payments")
      budget_group.payment = true
      budget_group.purchase_request = true
      budget_group.invoice = true
      budget_group.purchase_order = true
    end
    budget_group.save!
    true
  end

end