Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.client_type == 'UserDeviceBrowser'
    # skip if RequestStoreUtil.current_request.remote_ip == '::1' and not Rails.env.production?
  end

  premise :on_authenticated_request do
    rule 'Request IP has to match Session IP' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      unless request.remote_ip == session.ip
        message 'Browser IP mismatch'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        fail
      end
    end

    rule 'Session should timeout after 30 minute of inactivity' do
      session = RequestStoreUtil.current_session

      if Time.now - Time.parse(session.last_request_at.to_s) > 30.minutes
        message 'Session timeout'
        session_status_id UserSessionStatus.id_for(:revoked)
        response_code 401
        fail
      end
    end
  end

end