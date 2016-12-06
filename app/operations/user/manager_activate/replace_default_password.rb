class User::ManagerActivate::ReplaceDefaultPassword < User::ManagerActivate::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
      return
    end
    unless params.present? and params[:user].present?
      messages[:error] << 'Error updating password'
      return
    end
    new_pwd_params = params[:user]
    unless new_pwd_params[:current_password].present?
      messages[:error] << 'Current password cannot be blank'
      return
    end
    unless new_pwd_params[:password].present?
      messages[:error] << 'New password cannot be blank'
      return
    end
    unless new_pwd_params[:password_confirmation].present?
      messages[:error] << 'Password confirmation cannot be blank'
      return
    end
  end

  def process
    unless user.update_with_password(password_params)
      messages[:error] = user.errors.full_messages
    end
    unless user.update_attributes(default_password: false)
      messages[:error] = user.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Password updated."
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
