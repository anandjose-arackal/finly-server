class User::Configuration::UpdatePassword < BaseOperation
  include Devise::Controllers::SignInOut

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
  end

  def post_process
    messages[:success] << "Password updated."
    request = RequestStoreUtil.current_request

    if user.email.present?
      # Send Email
      PasswordMailer.delay.notify_password_change(
          {
              to: user.email,
              user_agent: request&.user_agent,
              ip: request&.remote_ip,
              timestamp: DateTime.now.strftime("%I:%M %p, %d %b %Y")
          }
      )
    end
    if user.mobile_number.present?
      # Send SMS
      Sms::UserPasswordChange.(user, {})
    end
  end

  private
  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

end