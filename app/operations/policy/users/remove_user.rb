# to remove a user from a policy
# params:
# policy_id: the policy from which a user needs to be removed
# removed_user_id: the id of the user who needs to be removed.
# todo - generalize this to remove multiple users

class Policy::Users::RemoveUser < Policy::Base

  attr_accessor :removed_user

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def init
    self.policy = user.policies.find_by(id: params[:policy_id])
    self.removed_user = user.company.users.find_by(id: params[:removed_user_id] || params[:user_id])
  end

  def validate
    super()

  end

  def authorize
    unless removed_user
      raise_unauthorized_exception
      return false
    end
    if removed_user.policy_admin?(policy) and policy.admins.count <= 1
      raise_unauthorized_exception
      return false
    end
  end

  def process
    # Remove user
    unless self.policy.users.destroy(removed_user)
      errors << "Couldn't remove user from the policy."
      return false
    end
    # Remove user configuration
    user.team_mapping.policy(policy.id).destroy_all
  end

  def post_process
    if is_success?

    end
  end
end