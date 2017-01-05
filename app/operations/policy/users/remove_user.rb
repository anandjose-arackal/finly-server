# to remove a user from a policy
# params:
# policy_id: the policy from which a user needs to be removed
# removed_user_id: the id of the user who needs to be removed.

class Policy::Users::RemoveUser < Policy::Base

  attr_accessor :removed_users, :conflicting_users, :conflicts_present

  class Policy::Users::RemoveUser::RemovalPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :removed_users, :conflict, :conflict_messages, :policy, :users

    def init
      self.policy = params[:policy]
      self.removed_users = params[:removed_users]
      self.conflict_messages = params[:conflicting_users]
      self.conflict = params[:conflicts_present]
    end
  end

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def init
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id] || params[:id])
    ids = params[:user_id].split(',')
    self.removed_users = user.company.users.where(id: ids)
    self.conflicting_users = []
    self.conflicts_present = false
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

  def validate
    super()
    removed_users.each do |removed_user|
      messages = []
      conflicts = false
      auto_submit_config = removed_user.auto_submit_config
      if auto_submit_config.enabled and auto_submit_config.default_policy_id.present? and auto_submit_config.default_policy_id == self.policy.id
        messages << "#{removed_user.name} has this policy as their default policy for auto submission. Please update this before removing the user from the policy"
        self.removed_users -= [removed_user]
        conflicts = true
      end

      enforce_policy_config = removed_user.enforce_policy
      if enforce_policy_config.enabled and removed_user.policies.non_default.count == 1
        messages << "#{removed_user.name} has this policy as their default policy for auto submission. Please update this before removing the user from the policy"
        self.removed_users -= [removed_user]
        conflicts = true
      end
      if conflicts
        self.conflicting_users << {user: removed_user, message: messages}
        self.conflicts_present = true
      end
    end
  end

  def process
    removed_users.each do |removed_user|
      # Remove user
      unless self.policy.users.destroy(removed_user)
        add_message :error, "Couldn't remove user from the policy."
        return false
      end
      # Remove user configuration
      removed_user.team_mapping.policy(policy.id).destroy_all
    end
  end

  def post_process
    add_message :success, "User removed from policy."
  end

  def success
    Policy::Users::RemoveUser::RemovalPresenter.new(user, {policy: policy, conflicting_users: conflicting_users, removed_users: removed_users, conflicts_present: conflicts_present, users: policy.users}, messages)
  end

end