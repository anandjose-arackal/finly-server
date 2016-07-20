class PolicyUserService < BaseService
  attr_accessor :policy

  def initialize(policy)
    super()
    self.policy = policy
  end

  def invitable_users
    policy.company.users.without_id(policy.users.pluck(:id))
  end

  # adds a particular user and his associated role within the policy
  def add_user(user, is_admin=false)
    errors.clear
    if user.blank?
      errors << 'No user selected'
      return false
    end
    if self.policy.users.find_by(id: user.id).present?
      errors << 'User already added'
      return false
    end

    # Add user to policy mapping
    self.policy.user_mapping.create(user: user, admin: is_admin)

    # Add user configuration
    user.team_mapping.policy(nil).each do |item|
      cloned_item = item.dup
      cloned_item.update_attribute(:policy_id, self.policy.id)
    end
    true
  end

  def remove_user(user)
    errors.clear
    if user.blank?
      errors << 'No user selected'
      return false
    end

    if self.policy.users.find_by(id: user.id).blank?
      errors << 'User not found in policy'
      return false
    end

    # Remove user configuration
    user.team_mapping.policy(policy.id).destroy_all

    # Remove user
    self.policy.users.destroy(user) if user.present?
  end

end