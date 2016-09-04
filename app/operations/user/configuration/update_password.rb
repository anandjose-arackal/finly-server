class User::Configuration::UpdatePassword < BaseOperation
  include Devise::Controllers::SignInOut

  def pre_validate
    unless user.present?
      errors << 'User not found'
      return
    end
    unless params.present? and params[:user].present?
      errors << 'Error updating password'
      return
    end
    new_pwd_params = params[:user]
    unless new_pwd_params[:current_password].present?
      errors << 'Current password cannot be blank'
    end
    unless new_pwd_params[:password].present?
      errors << 'New password cannot be blank'
    end
    unless new_pwd_params[:password_confirmation].present?
      errors << 'Password confirmation cannot be blank'
    end
  end

  def process
    if user.update_with_password(password_params)
      sign_in @user, :bypass => true
    else
      errors << user.errors.full_messages
    end
  end

  private
  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end