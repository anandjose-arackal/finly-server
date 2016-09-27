class User::Team::Mappings::Reset < User::Team::Mappings::Base

  def pre_validate
    super
    unless params[:policy_id].present?
      messages[:error] << 'Cannot reset default policy'
    end
  end

  def validate
    if policy.blank? or policy.default
      messages[:error] << 'Cannot reset default policy'
      return
    end
    super
  end

  def process
    mappings.destroy_all
    self.updating_user.team_mapping.policy(nil).each do |item|
      clone = item.deep_clone
      clone.policy_id = params[:policy_id]
      if clone.greater_than_amount.present?
        amount = clone.greater_than_amount.deep_clone
        amount.save
        clone.greater_than_amount = amount
      end
      messages[:error] = clone.errors.full_messages unless clone.save
    end
  end

end