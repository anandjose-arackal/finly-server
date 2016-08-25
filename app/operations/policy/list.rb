# listing of the policies associated with a user.
# params:
# view: the view for the policy listing - admin, policy_admin, or personal.

class Policy::List < Policy::Base

  attr_accessor :view

  def self.call(user)
    self.new(user).run
  end

  def init
    self.view = params[:view]
  end

  def retrieve
    if view == 'admin' and user.admin? # Admin can view all policies
      user.company.policies.non_default if user.company.policies
    elsif view == 'policy_admin' and user.policy_admin?
      # i.e. all policies this user is an admin for
      user.admin_policies if user.admin_policies
    elsif view == 'personal' or view.nil? # User would get a list of policies he is added to
      user.policies.non_default if user.policies
    end
  end
end