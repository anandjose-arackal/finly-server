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
    if admin_view?
      if user.company_admin?
        self.policies = user&.company.policies
      else
        self.policies = user&.admin_policies
      end
    else
      self.policies = user&.policies
    end
  end

  def post_process
    self.policies = self.policies&.exclude_deleted
  end

  def success
    Policy::Index::IndexPresenter.new(user, {policies: policies}, messages)
  end

  class Policy::Index::IndexPresenter < Policy::Base::PolicyPresenter
    attr_accessor :policies

    def init
      self.policies = params[:policies]
    end
  end

end