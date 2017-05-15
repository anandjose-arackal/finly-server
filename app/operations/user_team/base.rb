class UserTeam::Base < BaseOperation
  attr_accessor :user_team

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:id).present?
      add_message :error, 'Team not found'
    end
  end

  def init
    self.user_team = user.company.user_teams.find_by(id: params[:id])
  end

  def validate
    if params&.dig(:id).present? and self.user_team.blank?
      add_message :error, 'Team not found'
    end
  end

end