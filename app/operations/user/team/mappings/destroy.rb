class User::Team::Mappings::Destroy < User::Team::Mappings::Base
  attr_accessor :updating_mapping

  def pre_validate
    super
    unless params[:user_team_mapping_id].present?
      messages[:error] << 'Nothing to remove'
    end
  end

  def pre_authorize
    user_id = (params[:id] or params[:user_id])
    if user.company_admin?
      self.updating_user = user.company.users.with_id(user_id).first rescue nil
    elsif user.policy_admin?
      if params[:user_manager_mapping].present?
        admin_policy_id = user.admin_policies.pluck(:id)
        params[:user_manager_mapping].each do |key, mapping|
          unless admin_policy_id.include?(mapping[:mapping_id])
            messages[:error] << 'You do not have the permission to make the following update'
            raise_unauthorized_exception
          end
        end
      end
      team = User::Team::Index.(user, view: 'admin')
      self.updating_user = team.with_id(user_id).first rescue nil
    end
  end

  def init
    self.updating_mapping = updating_user.team_mapping.with_id(params[:user_team_mapping_id]).first rescue nil
  end

  def authorize
    unless self.updating_mapping.present?
      messages[:error] << 'Team mapping not found'
      raise_unauthorized_exception
    end
  end

  def process
    unless self.updating_mapping.destroy
      messages[:error] = self.updating_mapping.errors.full_messages
    end
  end

  def post_process
    messages[:success] << 'Team updated successfully'
  end

end