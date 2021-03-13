class GoogleOauth2Controller < Oauth::TokenController

  include ApplicationHelper
  include ActiveSupport::Concern
  include ActionController::Instrumentation

  skip_before_action :verify_authenticity_token, raise: false

  def create
    RequestStore.store[:google_oauth2] = true
    set_grant_type
    set_scope
    super()
    @token.update_columns(authentication_type: "sso")
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

