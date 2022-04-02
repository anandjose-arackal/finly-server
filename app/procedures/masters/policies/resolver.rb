class Masters::Policies::Resolver < Resolver::API

  entity Policy

  def load(params)
    if user.company_admin? || user.auditor? || user.vendor_payments_admin?
      ids = user&.company.policies.with_application(app).pluck(:id)
      policies = Policy.with_id(ids)
    else
      case app
      when 'em', :em
        if user&.enforce_policy_enabled?
          ids = user&.policies.non_default.with_application(app).pluck(:id)
        else
          ids = user&.policies.pluck(:id)
        end
      else
        if user&.enforce_policy_enabled?
          ids = user.company.policies.non_default.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id).pluck(:id)&.uniq
        else
          ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id).pluck(:id)&.uniq
        end
      end
      policies = Policy.with_id(ids)
    end
    policies

    if params[:permissions].present?
      op = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.ids_for(params[:permissions])]})
      policies = op.policies
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