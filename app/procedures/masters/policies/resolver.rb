class Masters::Policies::Resolver < Resolver::API

  entity Policy

  def load(params)

    # if admin_view? || auditor_view?
    if user.company_admin? || user.auditor? || user.vendor_payments_admin?
      if user&.enforce_policy_enabled?
        ids = []
      else
        ids = user&.policies.default.pluck(:id)
      end
      ids += user&.company.policies.with_application(app).pluck(:id)
      policies = Policy.with_id(ids)
    else
      if user&.enforce_policy_enabled?
        ids = []
      else
        ids = user&.policies.default.pluck(:id)
      end
      ids += user&.admin_policies.with_application(app).pluck(:id)
      policies = Policy.with_id(ids)
    end
    policies

    # # else
    #   if user&.enforce_policy_enabled?
    #     ids = []
    #   else
    #     ids = user&.policies.default.pluck(:id)
    #   end
    #   ids += user&.policies.with_application(current_app).pluck(:id)
    #   self.policies = Policy.with_id(ids).exclude_deleted
    # end


    # return user.company.policies if user.admin? and not params[:permissions]

    # policy_mapping = user.policy_user_roles
    # if params[:permissions].present?
    #   policy_mapping = policy_mapping.where(user_role_id: UserRole.ids_for(params[:permissions]))
    # end

    # Policy.where(id: policy_mapping.pluck(:policy_id))
  end

end