# action to create policies
# params:
# name: Name of the policy that needs to be created.

class Policy::Create < Policy::Base

  attr_accessor :company, :cloned_policy

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      messages[:error] << "No user passed."
      return false
    end
    if params[:name].blank?
      messages[:error] << "Cannot create policy without name."
      return false
    end
  end

  def init
    self.company = user.company
  end

  def authorize

  end

  def process
    self.cloned_policy = company.policies.default.first.deep_clone except: [:users, :user_mapping]
    cloned_policy.name = params[:name]
    cloned_policy.default = false
    if cloned_policy.save
      self.policy = cloned_policy
      return true
    end
    messages[:error] = cloned_policy.errors.full_messages
  end

  def post_process
    if success?
      add_user_op = Policy::Users::AddUser.new(user, {policy_id: cloned_policy.id, user_id: user.id.to_s, admin: true})
      # Add the creating user as admin
      add_user_op.run
      messages[:success] << 'New Policy created!'
      cloned_policy
    end
  end

  def success
    # Policy::Base::PolicyPresenter.new(user, {policy: policy, view: params[:view]})
    Policy::Index.(user, params)
  end

end