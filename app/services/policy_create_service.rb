class PolicyCreateService < BaseService

  def create_policy(company, name)
    errors.clear
    cloned_policy = company.policies.default.deep_clone except: [:users, :user_mapping]
    cloned_policy.name = name
    cloned_policy.default = false
    errors << cloned_policy.errors.full_messages unless cloned_policy.save
    return cloned_policy if errors.blank?
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