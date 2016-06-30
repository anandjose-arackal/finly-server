class PolicyUserService < BaseService
  attr_accessor :policy

  def initialize(policy)
    self.policy = policy
  end

  def add_user(user)
    # Add user to mapping
    self.policy.user_mapping.create(user: user, policy_user_role_id: 4)

    # Add user configuration
    user.team_mapping.policy(nil).each do |item|
      cloned_item = item.dup
      cloned_item.update_attribute(:policy_id, self.policy.id)
    end
  end

  def remove_user(user)
    # Remove user configuration
    user.team_mapping.policy(policy_id).each do |item|
      item.destroy
    end
    # Remove user
    self.policy.users.delete(user) if user.present?
  end

  def update_user_role(user, policy_user_role_id)
    map = PolicyUserMapping.policy_user_map(policy, user)
    return map.update_attribute(:policy_user_role_id, policy_user_role_id) if map.present?
    errors << 'User not found in the policy'
    false
  end

end