class Masters::Policies::Resolver < Resolver::API

  entity Policy

  def load(params)
    return user.company.policies if user.admin? and not params[:permissions]

    policy_mapping = user.policy_user_roles
    if params[:permissions].present?
      policy_mapping = policy_mapping.where(role_id: UserRole.ids_for(params[:permissions]))
    end

    Policy.where(id: policy_mapping.pluck(:policy_id))
  end

end