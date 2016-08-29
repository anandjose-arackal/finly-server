# the class that updates an invite after the face.
# params:
# manager_id, finance_manager_id, conditional manager ids - all team mapping attributes
# manager, finance_manager, admin - all individually 0 or 1 depending on the role this employee is assigned.

class User::Invite::Update < User::Invite::Base

  attr_accessor :invited_user, :user_team_service

  def pre_validate
    if user.blank? or params.blank?
      errors << "User or params is blank"
    end
  end

  def init
    self.invited_user = User.pending.find_by(id: user_id)
    # creating a uts object to manipulate the invited user's attributes
    self.user_team_service = UserTeamService.new(self.invited_user)
  end

  def validate
    unless invited_user
      errors << "User to be updated not found."
    end
  end

  def authorize
    unless user.admin? or user.id == invited_user.invited_by
      errors << 'Only inviting users or admins can delete invites.'
      return false
    end
  end

  def process
    unless user_team_service.update(params)
      errors << user_team_service.errors
      return false
    end
    if params[:manager] == '1'
      user_team_service.update_role(user_role_id: 3)
    elsif params[:manager] == '0' and user.manager?
      user_team_service.remove_role(user_role_id: 3)
      # removing his approves_to
      user.team_mapping.default.first.update_attributes(:approves_to, nil)
    end
    if params[:finance_manager] == '1'
      user_team_service.update_role(user_role_id: 2)
    elsif params[:finance_manager_id] == '0' and user.finance_manager?
      user_team_service.remove_role(user_role_id: 2)
      # removing his approves_finance_to
      user.team_mapping.default.first.update_attributes(:approves_finance_to, nil)
    end
    if params[:admin] == '1'
      user_team_service.update_role(user_role_id: 1)
    elsif params[:finance_manager_id] == '0' and user.admin?
      user_team_service.remove_role(user_role_id: 1)
    end
  end
end