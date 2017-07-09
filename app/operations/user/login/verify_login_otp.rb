# action that verifies the login otp of the user

class User::Login::VerifyLoginOtp < BaseOperation

  attr_accessor :selected_user, :set_password_token

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Internal error, try again'
    end
  end

  def init
    self.selected_user = User.find_for_database_authentication(username: params[:email_mobile])
  end

  def validate
    unless params[:otp].present?
      add_message :error, 'Please enter your OTP for validation'
      return
    end
    unless selected_user
      add_message :error, 'User not found'
      return
    end
    unless selected_user.otp == params[:otp]
      add_message :error, 'Wrong OTP entered. Please enter the OTP sent to your mobile number'
    end
  end

  def authorize

  end

  def process
    # skipping validations because users from the mobile number invite flow won't have their details filled in yet
    selected_user.assign_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
    selected_user.save(validate: false)
  end

  def post_process
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)
    self.set_password_token = raw
    selected_user.update_attribute(:reset_password_token, enc)
    selected_user.update_attribute(:reset_password_sent_at, DateUtils.local_date_time)
  end

  def success
    params[:set_password_token] = self.set_password_token
    User::Login::VerifyLoginOtp::OtpPresenter.new(user, params, messages)
  end

  class User::Login::VerifyLoginOtp::OtpPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :set_password_token

    def init
      self.set_password_token = params[:set_password_token]
    end

  end

end