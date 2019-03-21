class Policy::VendorPayments::Index < Policy::Base
  attr_accessor :policies, :policy_user_roles

  def init
  end

  def authorize
  end


  def process
    # If enfore_policy is enabled, do not consider default policies
    if user.vendor_payments_admin? || user.vendor_payments_auditor?
      if user&.enforce_policy_enabled?
        ids = user.company.policies.joins(:policy_user_roles).where("policy_user_roles.user_role_id IN (?) AND policy_user_roles.user_id = ?", UserRole::VP_ROLES.values, user.id)
      else
        ids = user.company.policies.joins(:policy_user_roles).where("policy_user_roles.user_role_id IN (?) AND policy_user_roles.user_id = ?", UserRole::VP_ROLES.values, user.id)&.pluck(:id)
      end
    else
      if user&.enforce_policy_enabled?
        ids = user.company.policies.joins(:policy_user_roles).where.not(default: true).where('policy_user_roles.user_id = ?', user.id).pluck(:id)&.uniq
      else
        ids = user&.policy_user_roles.pluck(:policy_id)&.uniq
      end
    end
    self.policy_user_roles = ::PolicyUserRole.where(policy_id: ids)
  end

  def post_process
    self.policy_user_roles = self.policy_user_roles
  end

  def success
    params[:policy_user_roles] = self.policy_user_roles
    Policy::VendorPayments::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::VendorPayments::Index::IndexPresenter < Policy::Base::PolicyPresenter
    include HasScope
    attr_accessor :policies, :policy_user_roles, :admin_policies

    has_scope :filter_role_id, type: :array

    def init
      self.policy_user_roles = params[:policy_user_roles]
      self.policy_user_roles = apply_scopes(policy_user_roles)
      self.policy_user_roles = self.policy_user_roles.where(user_id: user.id)&.uniq
      self.policies = Policy.where(id: policy_user_roles&.pluck(:policy_id)&.uniq)&.exclude_deleted
      # Jugaad as we do not have policy admin in place
      self.admin_policies = user.company.policies.exclude_deleted
    end
  end
end