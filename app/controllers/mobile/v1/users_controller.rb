class  Mobile::V1::UsersController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session


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
    @result.config[:mobile_api] = true
    respond
  end

  def verify_user_otp
    @result = User::Login::VerifyLoginOtp.(params)
    @result.config[:mobile_api] = true
    respond
  end

end
