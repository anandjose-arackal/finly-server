class Masters::Policies::Resolver < Resolver::API

  entity Policy

  def load(params)
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
    

    if params[:permissions].present?  
      policies = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.ids_for(params[:permissions])]}).policies
    end
    policies


    #   policy_mapping = policy_mapping.where(user_role_id: UserRole.ids_for(params[:permissions]))

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

  end

end