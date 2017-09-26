class UserTeam::Destroy < UserTeam::Base

  def authorized_user_types
    [:company_admin, :auditor]
  end

  def process
    unless user_team.destroy
      add_message :error, user_team.errors.full_messages
    end
  end

end