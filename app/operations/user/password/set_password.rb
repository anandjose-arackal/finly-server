# sets the password for a user

class User::Login::SetPassword < BaseOperation

  attr_accessor :password_params

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.password_params = password_parameters
    password_params[:default_password] = false
  end

  def validate
    if password_params[:password].blank?
      add_message :error, "Password cannot be blank"
      return
    end
    if password_params[:password_confirmation].blank?
      add_message :error, "Password confirmation cannot be blank"
      return
    end
    if password_params[:password] != password_params[:password_confirmation]
      add_message :error, "Password and password confirmation have to match"
    end
  end

  def process
    unless user.update_attributes(password_params)
      add_message :error, user.errors.full_messages.to_sentence
    end
  end

  private

  def password_parameters
    params.require(:user).permit(:password, :password_confirmation, :default_password)
  end
end