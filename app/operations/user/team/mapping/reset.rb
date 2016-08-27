class User::Team::Mapping::Reset < User::Team::Mapping::Base

  def pre_validate
    super
    unless params[:policy_id].present?
      errors << 'Cannot reset default policy'
    end
  end

  def validate
    if policy.blank? or policy.default
      errors << 'Cannot reset default policy'
      return
    end
    super
  end

  def process
    mappings.destroy_all
    self.updating_user.team_mapping.policy(nil).each do |item|
      clone = item.dup
      clone.policy_id = params[:policy_id]
      errors << clone.errors.full_messages unless clone.save
    end
  end

end