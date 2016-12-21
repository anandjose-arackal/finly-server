class PolicyCreateService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user = user
  end

  def create_policy(name)
    errors.clear
    unless user.present?
      errors << 'User not found'
      return false
    end
    unless user.company_admin?
      errors << 'Only admins can create policies'
      return false
    end
    if name.blank?
      errors << 'Cannot create policy without a name'
      return false
    end
    company = user.company
    cloned_policy = company.policies.default.first.deep_clone except: [:users, :user_mapping]
    cloned_policy.name = name
    cloned_policy.default = false
    errors << cloned_policy.errors.full_messages unless cloned_policy.save
    if errors.blank?
      user_service = PolicyUserService.new(cloned_policy)
      # Add the creating user as admin
      user_service.add_user user, true
      return cloned_policy
    end
    false
  end

  def clone_policy(policy, name, params={})
    errors.clear
    items_to_clone = [:configuration]
    if params[:user]
      items_to_clone << :user_mapping
      items_to_clone << :user_team_mapping
    end
    cloned_policy = policy.deep_clone include: items_to_clone
    cloned_policy.name = name
    cloned_policy.default = false if policy.default
    errors << cloned_policy.errors.full_messages unless cloned_policy.save
    return cloned_policy if errors.blank?
    false
  end

end