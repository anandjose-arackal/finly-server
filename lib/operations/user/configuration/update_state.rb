# action for admin to activate or deactivate a user
# params :
# user:
#      active: true or false depending on active or inactive

class User::Configuration::UpdateState < BaseOperation

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or params not passed."
    end
  end

  def init
    id = params[:id] or params[:to_user_id]
    self.to_user = user.company.users.find_by(id: id)
  end

  def authorize
    team = User::Team::Index.(user, params)
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def process
    unless to_user.update(state_params)
      messages[:error] << to_user.errors.full_messages
    end
  end

  def success
    self.to_user
  end

  private

  def state_params
    params.require(:user).permit(:active)
  end
end