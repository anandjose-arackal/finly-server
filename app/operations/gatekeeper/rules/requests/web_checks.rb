Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.web?
    skip if RequestStoreUtil.current_session.admin_user_id.present?
  end

  premise :on_authenticated_request do

    # todo temporary
    # rule 'Request IP has to be a verified UserIP' do
    #   pass = false
    #   [
    #       'otp/resend',
    #       'otp/verify',
    #   ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
    #   next if pass
    #
    #   request = RequestStoreUtil.current_request
    #   session = RequestStoreUtil.current_session
    #   next if request.remote_ip == session.ip
    #   next if request.remote_ip == session.user_ip&.ip
    #   # Allow the request as long as the request is from a verified IP
    #   next if RequestStoreUtil.current_user.user_ips.find_by_ip(request.remote_ip).present?
    #   next if Rails.env.development?
    #
    #   message 'Unverified IP'
    #   session_status_id UserSessionStatus.id_for(:blocked)
    #   response_code 401
    #   level 3
    #   fail
    # end

    rule 'UserAgent is required for the request' do
      if RequestStoreUtil.current_request.user_agent.nil?
        message 'User agent is blank in the request'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        level 3
        fail
      end
    end

    # rule 'Request UserAgent has to match Session UserAgent' do
    #   request = RequestStoreUtil.current_request
    #   session = RequestStoreUtil.current_session
    #   next if request.user_agent == session.user_agent
    #
    #   message 'UserAgent mismatch'
    #   session_status_id UserSessionStatus.id_for(:blocked)
    #   response_code 401
    #   level 1
    #   fail
    #
    # end

    rule 'X-Finly-RP is required for all web requests' do
      next if RequestStoreUtil.x_finly_rp_attributes.present?
      next if RequestStoreUtil.skip_x_finly_rp_check?

      message 'X-Finly-RP not sent'
      session_status_id UserSessionStatus.id_for(:blocked)
      response_code 401
      level 10
      fail
    end

    rule 'Session should timeout on inactivity' do
      session = RequestStoreUtil.current_session
      policy = RequestStoreUtil.security_policy

      next if policy.browser_client.inactivity_timeout.nil?

      if Time.now - Time.parse(session.last_request_at.to_s) > policy.browser_client.inactivity_timeout
        message 'Session timeout'
        session_status_id UserSessionStatus.id_for(:expired)
        response_code 401
        level 1
        fail
      end
    end

  end

end