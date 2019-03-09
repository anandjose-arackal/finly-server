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

    # # todo Temporary as device is not available at the moment because of lack of frontend dev
    # rule 'User agent is required for the request' do
    #   if RequestStoreUtil.current_request.user_agent.nil?
    #     message 'User agent is blank in the request'
    #     session_status_id UserSessionStatus.id_for(:blocked)
    #     response_code 401
    #     fail
    #   end
    # end
    #
    # rule 'User agent has to match session user agent' do
    #   if RequestStoreUtil.current_request.user_agent != RequestStoreUtil.current_session.user_agent
    #     message 'User agent does not match the user session user agent'
    #     session_status_id UserSessionStatus.id_for(:blocked)
    #     response_code 401
    #     fail
    #   end
    # end
    # # todo Temporary as device is not available at the moment because of lack of frontend dev
  end

end