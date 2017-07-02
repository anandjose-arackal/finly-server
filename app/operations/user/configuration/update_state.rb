# action for admin to activate or deactivate a user
# params :
# user:
#      active: true or false depending on active or inactive

class User::Configuration::UpdateState < BaseOperation
  attr_accessor :to_user

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User or params not passed'
      return
    end
    require_password_validation = true
    unless params[:validate_password].nil?
      require_password_validation = !!params[:validate_password]
    end
    if require_password_validation
      if params[:password].blank?
        add_message :error, 'You need to provide your password to complete this action'
        return
      end
      unless self.user.valid_password?(params[:password])
        add_message :error, 'Invalid password'
      end
    end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = User::Team::Index.(user, params).with_id(id).first rescue nil
  end

  def authorize
    if to_user.blank?
      raise_unauthorized_exception
    end
  end

  def validate
    if to_user.id == user.id
      add_message :error, 'You cannot activate / deactivate yourself'
    end
  end

  def process
    if to_user.update(state_params)
      update_card
      return
    end
    add_message :error, to_user.errors.full_messages
  end

  private

  def state_params
    params.permit(:active)
  end

  def update_card
    return unless to_user.cards.present?
    if to_user.active
      User::PrepaidCard::Unblock.(self.user, user: to_user, user_deactivation: true, password: params[:password])
    else
      User::PrepaidCard::Block.(self.user, user: to_user, user_deactivation: true, password: params[:password])
    end
  end
end