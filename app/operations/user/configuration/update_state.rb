# action for admin to activate or deactivate a user
# params :
# user:
#      active: true or false depending on active or inactive

class User::Configuration::UpdateState < BaseOperation
  attr_accessor :to_user

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or params not passed."
    end
  end

  def init
    params[:view] = 'admin'
    id = params[:id] or params[:to_user_id]
    self.to_user = User::Team::Index.(user, params).with_id(id).first rescue nil
  end

  def authorize
    if to_user.blank?
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