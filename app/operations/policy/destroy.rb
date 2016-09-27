# action to destroy a policy - deleting a policy will remove its association with all members.
# params:
# policy_id : policy that needs to be deleted

class Policy::Destroy < Policy::Base

  attr_accessor :view

  def authorized_user_types
    [:admin, :policy_admin]
  end

  def init
    self.view = params[:view]
    self.policy = Policy::Index.(user, view: view).policies.find_by(id: params[:policy_id] || params[:id])
  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end

  def process
    unless self.policy.destroy
      messages[:error] << "Couldn't delete policy. PLease try again"
    end
  end

  def post_process
    messages[:success] << 'Policy destroyed'
  end

  def success
    # Policy::Base::PolicyPresenter.new(user, {view: params[:view]})
    Policy::Index.(user, params)
  end

end