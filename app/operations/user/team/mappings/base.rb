class User::Team::Mappings::Base < User::Team::Base
  attr_accessor :updating_user, :policy

  def pre_validate
    if user.blank? or (params[:user_id].blank? and params[:id].blank?)
      errors << 'User not found'
    end
  end

  def pre_authorize
    if user.company_admin?
      if params[:policy_id].present?
        self.policy = user.company.policies.with_id(params[:policy_id]).first rescue nil
      else
        self.updating_user = user.company.users.with_id(params[:user_id]).first rescue nil
        return
      end
    elsif user.policy_admin?
      if params[:policy_id].blank?
        raise_unauthorized_exception
      end
      self.policy = user.admin_policies.with_id(params[:policy_id]).first rescue nil
    end
    raise_unauthorized_exception unless self.policy.present?
    self.updating_user = self.policy.users.with_id(params[:user_id]).first rescue nil
  end

  def init
    self.mappings = updating_user.team_mapping.policy(params[:policy_id])
  end

  def authorize
    if self.mappings.blank?
      errors << 'Configuration not found'
      raise_unauthorized_exception
    end
  end

  def validate
    if self.updating_user.blank?
      errors << 'User not found in policy'
    end
  end

end