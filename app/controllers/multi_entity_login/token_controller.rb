class MultiEntityLogin::TokenController < Oauth::TokenController

  def create
    RequestStore.store[:multi_entity_login] = true
    super()
  end

  def create_user_sessions
    # Reuse previous session
    token = Doorkeeper::AccessToken.find_by(token: params[:auth_token])
    session = ActsAsTenant.without_tenant do
      UserSession.find_by(access_token_id: token&.id)
    end

    @token.update authentication_type: token.authentication_type

    merged_params = params.merge(
        {
            user_device: session.user_device,
            user_ip: session.user_ip,
            user_agent_client: session.user_agent_client,
            admin_user_id: session.admin_user_id,
            admin_access_reason: session.admin_access_reason,
            admin_access_reason_details: session.admin_access_reason_details,
            admin_access_requested_by: session.admin_access_requested_by
        }
    )
    sessions_result = UserSessions::Create.(:authorized, merged_params)
    sessions_result.success? and sessions_result.session.status_id == UserSessionStatus.id_for(:authorized)
  end

  def on_session_create
    true
  end

end