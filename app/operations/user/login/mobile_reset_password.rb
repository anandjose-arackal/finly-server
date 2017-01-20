class User::Login::MobileResetPassword < BaseOperation

  attr_accessor :selected_user, :accept_params, :temp_password

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.accept_params = {}
    self.selected_user = User.find_by(mobile_number: params[:user][:email])
  end

  def validate
    if selected_user.blank?
      add_message :error, "User not found"
    end
  end

  def process
    # assign a password to the user, and send him the password on mobile. Then save it as the temporary password to be sent
    self.temp_password = generate_random_string(4)
    self.accept_params[:password] = self.accept_params[:password_confirmation] = temp_password
    accept_params[:default_password] = true
    unless selected_user.update_attributes(accept_params)
      add_message :error, "Could not reset password. Try again"
    end
  end

  def post_process
    message = "Your temporary password is: #{temp_password}. You will be asked to change it upon signing in. Please do not share this information with anyone"
    # sending the one time password as an SMS. Mobile number is to be sent as an array of mobile numbers
    WelcomeMessage::Create.(user, {mobile_number: [selected_user.mobile_number], message: message})

    add_message :success, "You will get a message with instructions"
  end

  def generate_random_string(length = 5)
    SecureRandom.hex(length)
  end
end