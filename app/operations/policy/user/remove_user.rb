# to remove a user from a policy
# params:
# policy_id: the policy from which a user needs to be removed
# removed_user_id: the id of the user who needs to be removed.
# todo - generalize this to remove multiple users

class Policy::User::RemoveUser < Policy::Base

  attr_accessor :removed_user

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def init
    self.policy = user.policies.find_by(id: params[:policy_id])
    self.removed_user = User.find_by(id: params[:removed_user_id])
  end

  def validate
    super()
    unless removed_user
      errors << "User to be removed not found in policy."
    end

    if self.policy.users.find_by(id: removed_user.id).blank?
      errors << "User not found in policy."
      return false
    end
  end

  def authorize
    unless user.policy_admin?(policy) and PolicyUserMapping.with_user(user.id).admin.count <= 1
      errors << 'Cannot remove the only admin from policy'
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