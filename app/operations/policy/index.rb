# listing of the policies associated with a user.
# params:
# view: the view for the policy listing - admin, policy_admin, or personal.

class Policy::Index < Policy::Base

  attr_accessor :view, :policies

  class Policy::Index::IndexPresenter < Policy::Base::PolicyPresenter

    attr_accessor :policies

    def initialize(user, params)
      self.policies = params[:policies]

    end
  end

  def self.call(user, params)
    self.new(user, params).run
  end

  def init
    self.view = params[:view]
  end

  def authorize

  end

  def process
    if view == 'admin' and user.admin? # Admin can view all policies
      self.policies = user.company.policies if user.company.policies
    elsif view == 'policy_admin' and user.policy_admin?
      # i.e. all policies this user is an admin for
      self.policies = user.admin_policies if user.admin_policies
    elsif view == 'personal' or view.nil? # User would get a list of policies he is added to
      self.policies = user.policies if user.policies
    end
  end

  def retrieve
    if is_success?
      index_presenter = Policy::Index::IndexPresenter.new(user, {policies: policies })
      return index_presenter
    else
      return false
    end
  end
end