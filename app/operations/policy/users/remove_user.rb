# to remove a user from a policy
# params:
# policy_id: the policy from which a user needs to be removed
# removed_user_id: the id of the user who needs to be removed.
# todo - generalize this to remove multiple users

class Policy::Users::RemoveUser < Policy::Base

  attr_accessor :removed_users

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id] || params[:id])
    ids = params[:user_id].split(',')
    self.removed_users = user.company.users.where(id: ids)
  end

  def validate
    super()

  end

  def authorize
    unless removed_users.present?
      raise_unauthorized_exception
      return false
    end
    removed_users.each do |removed_user|
      if removed_user.policy_admin?(policy) and policy.admins.count <= 1
        raise_unauthorized_exception
        return false
      end
    end
  end

  def process
    removed_users.each do |removed_user|
      # Remove user
      unless self.policy.users.destroy(removed_user)
        messages[:error] << "Couldn't remove user from the policy."
        return false
      end
      # Remove user configuration
      removed_user.team_mapping.policy(policy.id).destroy_all
    end
  end

  def post_process
    messages[:success] << "User removed from policy."
  end
end