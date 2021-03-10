class GoogleOauth2Controller < Oauth::TokenController

  include ApplicationHelper
  include ActiveSupport::Concern
  include ActionController::Instrumentation

  skip_before_action :verify_authenticity_token, raise: false

  # def google_auth2
  #     @redirect_url = '/auth/google_auth2'
  #   else
  #     @redirect_url = "/login"
  #   end
  #   render json: {redirect_url: @redirect_url}, status: 200
  # end

  # this will be the catch-all controller for SAML as well as Ouath strategies
  # The logic for choosing between the strategies will be held in the Authenticator::Processor operation
  def create
    auth = request.env['omniauth.auth']

    params[:info] =  auth.info
    params[:credentials] =  auth.credentials

    email = params[:info][:email]
    user = User.find_by(email: email)

    params[:email] = email
    params[:user] = user
    params[:company_id] = user.company_id

    RequestStore.store[:google_oauth2] = true
    set_grant_type
    set_scope
    super()
    @token.update_columns(authentication_type: "google_auth2")
  end

  def google_auth2_logout
    # yet to be implemented. When though?
  end


  protected

  def on_session_create
    super()
  end

  private

  def set_grant_type
    params[:grant_type] = "password"
  end
end

