# listing of the policies associated with a user.
# params:
# view: the view for the policy listing - admin, policy_admin, or personal.

class Policy::Index < Policy::Base
  attr_accessor :view, :policies

  def init
    self.view = params[:view]
  end

  def authorize

  end

  def process
    if admin_view? || auditor_view?
      if user.company_admin? || user.auditor? || user.vendor_payments_admin?
        if user&.enforce_policy_enabled?
          ids = []
        else
          ids = user&.policies.default.pluck(:id)
        end
        ids += user&.company.policies.with_application(current_app).pluck(:id)
        self.policies = Policy.with_id(ids)
      else
        if user&.enforce_policy_enabled?
          ids = []
        else
          ids = user&.policies.default.pluck(:id)
        end
        ids += user&.admin_policies.with_application(current_app).pluck(:id)
        self.policies = Policy.with_id(ids)
      end
    else
      if user&.enforce_policy_enabled?
        ids = []
      else
        ids = user&.policies.default.pluck(:id)
      end
      ids += user&.policies.with_application(current_app).pluck(:id)
      self.policies = Policy.with_id(ids)
    end
  end

  def post_process
    self.policies = self.policies&.exclude_deleted
  end

  def success
    params[:policies] = self.policies
    Policy::Index::IndexPresenter.new(user, params, messages)
  end

  class Policy::Index::IndexPresenter < Policy::Base::PolicyPresenter
    attr_accessor :policies

    def init
      self.policies = params[:policies]
    end
  end

end