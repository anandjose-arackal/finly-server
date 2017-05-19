class UserTeam::Destroy < UserTeam::Base

  def process
    unless user_team.destroy
      add_message :error, user_team.errors.full_messages
    end
  end

end