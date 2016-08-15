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
      cloned_item.policy_id = self.policy.id
      cloned_item.save
    end
    true
  end

  # adds a particular user and his associated role within the policy
  def add_users(users)
    errors.clear
    if users.blank?
      errors << 'No user selected'
      return false
    end
    users.each do |user|
      if self.policy.users.find_by(id: user.id).present?
        next
      end

      # Add user to policy mapping
      self.policy.user_mapping.create(user: user)

      # Add user configuration
      user.team_mapping.policy(nil).each do |item|
        cloned_item = item.dup
        cloned_item.policy_id = self.policy.id
        if cloned_item.greater_than_amount.present?
          amount = cloned_item.greater_than_amount.dup
          amount.save
          cloned_item.greater_than_amount = amount
        end
        cloned_item.save
      end
    end
    true
  end

  def remove_user(user)
    errors.clear

    unless self.policy.present?
      errors << 'Policy not found'
      return false
    end

    if user.blank?
      errors << 'No user selected'
      return false
    end

    if self.policy.users.find_by(id: user.id).blank?
      errors << 'User not found in policy'
      return false
    end

    unless user.policy_admin?(policy) and PolicyUserMapping.with_user(user.id).admin.count <= 1
      errors << 'Cannot remove the only admin from policy'
      return false
    end

    # Remove user
    self.policy.users.destroy(user)

    # Remove user configuration
    user.team_mapping.policy(policy.id).destroy_all
  end

  def remove_users(users)
    errors.clear

    unless self.policy.present?
      errors << 'Policy not found'
      return false
    end

    if users.blank?
      errors << 'No user selected'
      return false
    end

    # Check if all admins are being removed from the policy
    user_ids = users.pluck(:id)
    policy_admin_ids = PolicyUserMapping.with_policy(policy.id).admin.pluck(:user_id)
    if (policy_admin_ids - user_ids).blank?
      errors << 'You cannot remove all the admins from the policy'
      return false
    end

    users.each do |user|
      # Remove user configuration
      user.team_mapping.policy(policy.id).destroy_all

      # Remove user
      self.policy.users.destroy(user) if user.present?
    end
    true
  end

  def update_configuration(params={})
    errors.clear
    admin = params[:admin]
    user_id = params[:user_id]

    if self.policy.blank?
      errors << 'Policy not found'
      return false
    end
    user = self.policy.users.with_id(user_id)

    if user.blank?
      errors << 'User not found in policy'
      return false
    end
    user = user.first
    if user.blank?
      errors << 'User not found in policy'
      return false
    end
    policy_mapping = user.policy_user_mappings.with_policy(@policy.id)
    if policy_mapping.present? and as_boolean(admin) != policy_mapping.first.admin
      policy_mapping.first.update_attribute(:admin, as_boolean(admin))
    end

    mappings = user.team_mapping.policy(@policy.id)
    return false unless handle_mapping_update user, mappings, params[:default], true

    return false unless handle_mapping_update user, mappings, params[:conditional_manager]

    return false unless handle_mapping_update user, mappings, params[:conditional_finance_manager]

    return false unless handle_mapping_update user, mappings, params[:conditional_approves_to]

    return false unless handle_mapping_update user, mappings, params[:conditional_approves_finance_to]
    true
  end

  private
  def as_boolean(string)
    string.match(/(true|t|yes|y|1)$/i) != nil
  end

  def handle_mapping_update(user, mappings, params={}, default= false)
    if params[:mapping_id].present?
      mapping = mappings.with_id(params[:mapping_id])
      mapping = mapping.first if mapping.present?
      if mapping.blank?
        self.errors << 'User configuration load error'
        return false
      end
    else
      mapping = user.team_mapping.build(user: user, policy: self.policy, greater_than_amount_attributes: {value: 0, currency_id: 1})
    end
    if default
      default_config = nil
      if params[:manager_id].blank?
        if default_config.blank?
          default_config = user.team_mapping.without_policy.default.first
        end
        params[:manager_id] = default_config.manager_id
      end
      if params[:finance_manager_id].blank?
        if default_config.blank?
          default_config = user.team_mapping.without_policy.default.first
        end
        params[:finance_manager_id] = default_config.finance_manager_id
      end
      if params[:approves_to_id].blank?
        if default_config.blank?
          default_config = user.team_mapping.without_policy.default.first
        end
        params[:approves_to_id] = default_config.approves_to_id
      end
      if params[:approves_finance_to_id].blank?
        if default_config.blank?
          default_config = user.team_mapping.without_policy.default.first
        end
        params[:approves_finance_to_id] = default_config.approves_finance_to_id
      end
    end

    if params[:manager_id].blank? and params[:finance_manager_id].blank? and
        params[:approves_to_id].blank? and params[:approves_finance_to_id].blank?
      unless default
        if mapping.destroy!
          return true
        else
          self.errors += mapping.errors.full_messages
          return false
        end
      end
    end
    mapping.manager_id = params[:manager_id]
    mapping.finance_manager_id = params[:finance_manager_id]
    mapping.approves_to_id = params[:approves_to_id]
    mapping.approves_finance_to_id = params[:approves_finance_to_id]
    amount = params[:amount]
    if amount.present? and amount.to_f > 0
      mapping.greater_than_amount.value = amount.to_f
    else
      unless default
        self.errors << 'Cannot set amount value to 0 for conditional managers'
        return false
      end
      mapping.greater_than_amount = nil
    end
    if mapping.save
      return true
    end
    self.errors += mapping.errors.full_messages
    false
  end

end