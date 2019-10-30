class BudgetGroups::Create < Trailblazer::Operation

  step Model(BudgetGroup, :new)
  step Policy::Pundit(BudgetManager::BudgetAuthorizer, :create?)
  step :set_default_params

  # in the below step, we are telling TBZ which contract to use for this particular operation, inside "constant:"
  step Contract::Build(constant: BudgetGroups::Contract::Create)
  # in the next step, if the budget group is being sent within a key called 'budget_group' eg.
  # { "budget_group":
  #     {"name":
  #      "period":
  #     }
  # }
  # so here, we have to pass the topmost key so that TBZ knows the key to look for
  step Contract::Validate(key: 'budget_group')

  failure :return_error

  def set_default_params(options, params:, current_user:, **)
    params[:budget_group][:company_id] = current_user.company_id
    params[:budget_group][:created_by_user_id] = current_user.id
  end

  def return_error(options, **)
    return on_error options, :base, ""
  end

end