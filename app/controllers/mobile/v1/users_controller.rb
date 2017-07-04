class  Mobile::V1::UsersController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!, except: [:lookup, :send_verification_otp, :verify_user_otp, :set_new_password]

  respond_to :json

  def index
    @result = User::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def show
    @result = User::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def summary
    @result = User::Summary.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end
  
  def balance
    @result = User::Balance.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def lookup
    @result = User::Lookup.(params)
    @result.config[:mobile_api] = true
    respond
  end

  # action that sends the user an OTP before verifying them
  # params: mobile_number
  def send_verification_otp
    params[:type] = OtpRequestType.id_for(:set_or_forgot_password)
    @result = User::Login::SendVerificationOtp.(params)
    respond
  end

  def verify_user_otp
    @result = User::Login::VerifyLoginOtp.(params)
    respond
  end

  # action that lets mobile only users set their password for the first time
  # also the action that mobile users use to set their password if they've forgotten it
  def set_new_password
    @result = User::Login::SetPassword.(params)
    respond
  end

end