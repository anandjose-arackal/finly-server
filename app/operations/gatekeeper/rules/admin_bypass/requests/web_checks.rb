Gatekeeper::Checker.new 'AdminBypass > Request' do

  before do
    skip unless RequestStoreUtil.current_session&.web?
    skip unless RequestStoreUtil.current_session&.admin_user_id.present?
  end

  premise :on_authenticated_request do

    rule 'Request IP has to match Session IP' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      next if request.remote_ip == session.ip
      next if request.remote_ip == session.user_ip&.ip
      next if Rails.env.development?

      message 'Browser IP mismatch'
      session_status_id UserSessionStatus.id_for(:blocked)
      response_code 401
      level 3
      fail
    end

    rule 'User agent is required for the request' do
      if RequestStoreUtil.current_request.user_agent.nil?
        message 'User agent is blank in the request'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        level 3
        fail
      end
    end

    rule 'Request UserAgent has to match Session UserAgent' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      next if request.user_agent == session.user_agent

      message 'UserAgent mismatch'
      session_status_id UserSessionStatus.id_for(:blocked)
      response_code 401
      level 3
      fail

    end

    rule 'Session should timeout after 10 minute of inactivity' do
      session = RequestStoreUtil.current_session

      if Time.now - Time.parse(session.last_request_at.to_s) > 10.minutes
        message 'Session timeout'
        session_status_id UserSessionStatus.id_for(:revoked)
        response_code 401
        level 1
        fail
      end
    end

  end

end