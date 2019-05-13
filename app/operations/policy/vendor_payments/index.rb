# This operation is required until we have user roles implemented for expense management
class Policy::VendorPayments::Index < Policy::Base
  attr_accessor :policies, :policy_user_roles

  def init
  end

  def authorize
  end

  def authorized_user_types
    [:vendor_payments_admin, :vendor_payments_creditor, :vendor_payments_reviewer, :vendor_payments_initiator]
  end

  def validate
  end


  def process
    # If enfore_policy is enabled, do not consider default policies
    # Same API is being used by document create/edit page
    # Admin can see all policies on organisational account -> policy index
    # Admin can only see policies in which he is document initiator on any VP document's --> create/edit page
    #Hence segregating on the basis of api params
    if user.vendor_payments_admin? || user.vendor_payments_auditor?
      if user&.enforce_policy_enabled?
        # if params.dig(:menu, :main) == 'policies'
          # ids = user.company&.policies.with_application(current_app).exclude_deleted.where&.not(default: true)&.pluck(:id)
        # else
          ids = user.company&.policies&.joins(:policy_user_roles)&.where&.not(default: true)&.where("policy_user_roles.user_role_id IN (?) AND policy_user_roles.user_id = ?", UserRole::VP_ROLES.values, user.id)&.pluck(:id)
        # end
      else
        # if params.dig(:menu, :main) == 'policies'
          # ids = user.company.policies&.pluck(:id)
        # else
          ids = user.company.policies.joins(:policy_user_roles).where("policy_user_roles.user_role_id IN (?) AND policy_user_roles.user_id = ?", UserRole::VP_ROLES.values, user.id)&.pluck(:id)
        # end
      end
    else
      if user&.enforce_policy_enabled?
        ids = user.company.policies.joins(:policy_user_roles).where.not(default: true).where('policy_user_roles.user_id = ?', user.id).pluck(:id)&.uniq
      else
        ids = user&.policy_user_roles.pluck(:policy_id)&.uniq
      end
    end
    self.policy_user_roles = ::PolicyUserRole.with_policy_id(ids).with_user_id(user.id)
  end

  def post_process
    self.policy_user_roles = self.policy_user_roles.where(user_id: user.id)&.distinct
    self.policies = Policy.where(id: policy_user_roles&.pluck(:policy_id)&.uniq)&.with_application('vp')&.exclude_deleted if policy_user_roles.present?
    # d'uh, need to clean this operation
    if user.vp_admin_or_auditor?
      if user&.enforce_policy_enabled?
        self.policies = user.company&.policies.where.not(default: true).with_application('vp')&.exclude_deleted
      else
        self.policies = user.company&.policies.with_application('vp')&.exclude_deleted
      end
    end
  end

  def success
    params[:policy_user_roles] = self.policy_user_roles
    params[:policies] = self.policies
    Policy::VendorPayments::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::VendorPayments::Index::IndexPresenter < Policy::Base::PolicyPresenter
    include HasScope
    attr_accessor :policies, :policy_user_roles, :admin_policies

    has_scope :filter_role_id, type: :array

    def init
      self.policy_user_roles = params[:policy_user_roles]
      self.policies = params[:policies]
      self.policy_user_roles = apply_scopes(policy_user_roles)
      # for admin on policies index, filter_role_id will not be present
      # On document show , show only those policies to which user has initiator role even if user is admin
      if params.present? && params.has_key?(:filter_role_id)
        self.policies = self.policies.where(id: policy_user_roles&.pluck(:policy_id)) 
      end
      # Jugaad as we do not have policy admin in place
      # It's the company admin
      # Admin can see all policies in organizational account irrespective of enforce policy 
      self.admin_policies = user.company.policies.with_application('vp')&.exclude_deleted
    end
  end
end