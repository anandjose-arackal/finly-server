Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.client_type == 'UserDeviceBrowser'
    # skip if RequestStoreUtil.current_request.remote_ip == '::1' and not Rails.env.production?
  end

  premise :on_authenticated_request do
    rule 'Request IP has to match Session IP' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      next if request.remote_ip == session.ip
      next if request.remote_ip == session.user_ip&.ip

      message 'Browser IP mismatch'
      session_status_id UserSessionStatus.id_for(:blocked)
      response_code 401
      fail

    end

    rule 'Request UserAgent has to match Session IP' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      next if request.user_agent == session.user_agent

      message 'UserAgent mismatch'
      session_status_id UserSessionStatus.id_for(:blocked)
      response_code 401
      fail

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

    section 'Expired Users' do
      before do
        skip unless RequestStoreUtil.current_user.expired?
      end
      rule 'cannot access the system apart from SendOTP API, OTP Verification API and set password API' do
        [
            'send_verification_otp',
            'verify_user_otp',
            'users/password'
        ].each do |pattern|
          next unless RequestStoreUtil.current_request.path.include?(pattern)

          message 'User is expired'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
    end

    section 'OTP unverified Users' do
      before do
        skip unless RequestStoreUtil.current_user.otp_verified
      end

      rule 'cannot access the system apart from SendOTP API, OTP Verification API and set password API' do
        [
            'send_verification_otp',
            'verify_user_otp',
            'users/password'
        ].each do |pattern|
          next unless RequestStoreUtil.current_request.path.include?(pattern)

          message 'User OTP is not verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
    end

    section 'New Devices' do
      rule 'cannot access the system  apart from SendOTP API and OTP Verification API' do
        [
            'send_verification_otp',
            'verify_user_otp'
        ].each do |pattern|
          next unless RequestStoreUtil.current_request.path.include?(pattern)

          message 'New device is not OTP verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
    end

    section 'New IP' do
      rule 'cannot access the system  apart from SendOTP API and OTP Verification API' do
        [
            'send_verification_otp',
            'verify_user_otp'
        ].each do |pattern|
          next unless RequestStoreUtil.current_request.path.include?(pattern)

          message 'User IP is not OTP verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
    end

    # todo Check for all fields in X-Finly-RP
    # todo do not allow any api for incomplete, attribute_mismatch requests
    # todo set attribute mismatch
    # todo ensure user session, user device and user ip is created and verified

    rule 'User agent is required for the request' do
      if RequestStoreUtil.current_request.user_agent.nil?
        message 'User agent is blank in the request'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        fail
      end
    end

    rule 'User agent has to match session user agent' do
      if RequestStoreUtil.current_request.user_agent != RequestStoreUtil.current_session.user_agent
        message 'User agent does not match the user session user agent'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        fail
      end
    end
  end

end