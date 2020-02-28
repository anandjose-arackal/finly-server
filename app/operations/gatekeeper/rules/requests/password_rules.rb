Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.web?
    skip if RequestStoreUtil.current_session.admin_user_id.present?
    skip unless RequestStoreUtil.current_session.access_token.authentication_type == "password"
  end

  premise :on_authenticated_request do

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
          policy = RequestStoreUtil.security_policy
          skip unless policy.browser_client.otp_verify?
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

    section 'Verified Device' do

      before do
        skip if RequestStoreUtil.skip_x_finly_rp_check?
      end

      section 'X-Finly-RP property mismatch' do
        [
            #:user_agent,
            :timezone, :fingerprint, :language, :system_language,
            :browser, :browser_version, :browser_engine, :browser_engine_version,
            :os_name, :os_version,
            :screen_width, :screen_height, :device_x_dpi, :device_y_dpi, :color_depth,
            :java_enabled, :java_version, :flash_enabled, :flash_version, :silver_light_enabled,
            :silver_light_version,
            :is_mime_types, :mime_types_list,
            :fonts_list,
            :is_local_storage, :is_session_storage, :is_cookie,
            :plugins, :is_mobile
        ].each do |item|
          rule "#{item} property mismatch" do
            next if RequestStoreUtil.x_finly_rp_attributes[item].to_s == RequestStoreUtil.current_session.user_device.client.send(item).to_s

            session_status_id UserSessionStatus.id_for(:blocked)
            response_code 401
            fail
          end
        end

      end
    end

    section 'New IP' do
      section 'Unverified' do
        before do
          skip unless RequestStoreUtil.current_session.user_ip.status_id == UserIpStatus.id_for(:unverified)
          policy = RequestStoreUtil.security_policy
          skip unless policy.browser_ip.otp_verify?
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
          policy = RequestStoreUtil.security_policy
          skip unless policy.browser_user_agent.otp_verify?
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