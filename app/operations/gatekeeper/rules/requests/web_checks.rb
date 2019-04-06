Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.web?
    skip if RequestStoreUtil.current_session&.admin_user_id.present?
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

    rule 'Session should timeout after 30 minute of inactivity' do
      session = RequestStoreUtil.current_session

      if Time.now - Time.parse(session.last_request_at.to_s) > 30.minutes
        message 'Session timeout'
        session_status_id UserSessionStatus.id_for(:revoked)
        response_code 401
        level 1
        fail
      end
    end

    section 'Expired Users' do
      before do
        skip unless RequestStoreUtil.current_user.expired?
      end

      rule 'OTP Unverified user cannot access the system apart from SendOTP API, OTP Verification API' do
        next if RequestStoreUtil.current_user.otp_verified
        pass = false
        [
            'otp/resend',
            'otp/verify'
        ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
        next if pass

        message 'User is expired'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        level 5
        fail
      end

      # todo as devise uses a different controller, not usable at the moment
      # rule 'OTP verified user cannot access the system apart from SendOTP API, OTP Verification API and set password API' do
      #   next unless RequestStoreUtil.current_user.otp_verified
      #   pass = false
      #   [
      #       'otp/resend',
      #       'otp/verify',
      #       'users/password'
      #   ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
      #   next if pass
      #
      #   message 'User is expired'
      #   session_status_id UserSessionStatus.id_for(:blocked)
      #   response_code 401
      #   fail
      # end
    end

    section 'OTP unverified Users' do
      before do
        skip if RequestStoreUtil.current_user.otp_verified
      end

      rule 'cannot access the system apart from SendOTP API, OTP Verification API' do
        pass = false
        [
            'otp/resend',
            'otp/verify'
        ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
        next if pass

        message 'User OTP is not verified'
        session_status_id UserSessionStatus.id_for(:blocked)
        response_code 401
        level 5
        fail
      end
    end

    section 'New Devices' do
      section 'Unverified' do
        before do
          skip unless RequestStoreUtil.current_session.user_device.status_id == UserDeviceStatus.id_for(:unverified)
        end
        rule 'cannot access the system  apart from SendOTP API and OTP Verification API' do
          pass = false
          [
              'otp/resend',
              'otp/verify',
          ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
          next if pass

          message 'New device is not OTP verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
      section 'block :incomplete, :attribute_mismatch' do
        before do
          skip unless UserIpStatus.ids_for(:incomplete, :attribute_mismatch).include?(RequestStoreUtil.current_session.user_ip.status_id)
        end
        rule 'do not allow access' do
          message "User Device is #{RequestStoreUtil.current_session.user_ip.status.name}"
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          fail
        end
      end
    end

    section 'New IP' do
      section 'Unverified' do
        before do
          skip unless RequestStoreUtil.current_session.user_ip.status_id == UserIpStatus.id_for(:unverified)
        end
        rule 'cannot access the system  apart from SendOTP API and OTP Verification API' do
          pass = false
          [
              'otp/resend',
              'otp/verify',
          ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
          next if pass

          message 'User IP is not OTP verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          level 5
          fail
        end
      end

      section 'Blocked' do
        before do
          skip unless RequestStoreUtil.current_session.user_ip.status_id == UserIpStatus.id_for(:blocked)
        end
        rule 'do not allow access to blocked IPs' do
          message 'User IP is blocked'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          level 5
          fail
        end
      end
    end

    section 'New UserAgent' do
      section 'Unverified' do
        before do
          skip unless RequestStoreUtil.current_session.user_agent_client.status_id == UserAgentClientStatus.id_for(:unverified)
        end
        rule 'cannot access the system  apart from SendOTP API and OTP Verification API' do
          pass = false
          [
              'otp/resend',
              'otp/verify',
          ].each {|pattern| pass = true if RequestStoreUtil.current_request.path.include?(pattern)}
          next if pass

          message 'User IP is not OTP verified'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          level 5
          fail
        end
      end

      section 'Blocked' do
        before do
          skip unless RequestStoreUtil.current_session.user_agent_client.status_id == UserAgentClientStatus.id_for(:blocked)
        end
        rule 'do not allow access to blocked IPs' do
          message 'User IP is blocked'
          session_status_id UserSessionStatus.id_for(:blocked)
          response_code 401
          level 5
          fail
        end
      end
    end

    # todo Check for all fields in X-Finly-RP
    # todo do not allow any api for incomplete, attribute_mismatch requests
    # todo set attribute mismatch
    # todo ensure user session, user device and user ip is created and verified

  end

end