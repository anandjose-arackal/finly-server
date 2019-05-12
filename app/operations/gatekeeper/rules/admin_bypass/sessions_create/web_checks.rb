Gatekeeper::Checker.new 'AdminUserBypass > On Web Authentication' do

  premise :admin_bypass_login_attempt do
    section 'Domain check' do
      rule 'Only admin.finly.io can be used for accessing admin panel' do
        domain = RequestStoreUtil.current_request.domain
        subdomain = RequestStoreUtil.current_request.subdomains(0)&.first
        next if domain == 'finly.io' and subdomain == 'admin'

        message "Only admin.finly.io can be used for accessing admin panel. Attempted login with domain: #{domain} subdomain: #{subdomain}"
        level 10
        response_code 401
        fail
      end
    end

    section 'IP check' do
      rule 'Only authorized IP can be used for accessing admin panel' do
        admin_user = params[:admin_user]
        next if RequestStoreUtil.current_request.remote_ip == admin_user&.authorized_ip

        message "Admin Panel > Unauthorized IP > Attempted IP: #{RequestStoreUtil.current_request.remote_ip}"
        level 10
        response_code 401
        fail
      end
    end
  end

  premise :after_session_create do
    before do
      skip unless RequestStoreUtil.current_session.admin_user_id.present?
    end

    section 'X-Finly-RP' do
      # Web specific checks
      rule 'X-Finly-RP is required for all web requests' do
        headers = RequestStoreUtil.current_request.headers
        next if headers['X-Finly-RP'].present?
        response_code 401
        fail
      end

      # rule 'Associated device is required for all requests' do
      #   if RequestStoreUtil.current_user_device.blank?
      #     response_code 401
      #     fail
      #   end
      # end

      section 'If device is available' do
        before do
          skip if RequestStoreUtil.current_user_device.nil?
        end

        [:timestamp, :user_agent, :timezone, :fingerprint,
         :language, :browser, :browser_version,
         :browser_engine, :browser_engine_version,
         :os_name, :os_version].each do |property|
          rule "#{property} is required for all web requests" do
            web = RequestStoreUtil.current_user_device.client
            next unless web.send(property).blank?
            response_code 401
            fail
          end
        end

        rule 'Unverified devices need to be verified before proceeding' do
          next unless RequestStoreUtil.current_user_device.status_id == UserDeviceStatus.id_for(:unverified)
          require_otp true
        end

        [:incomplete, :attribute_mismatch, :complete].each do |status_name|
          rule "Do not allow login from devices with status #{status_name}" do
            web = RequestStoreUtil.current_user_device
            next unless web.status_id == UserDeviceStatus.id_for(status_name)
            response_code 401
            fail
          end
        end
      end

    end

    section 'UserSession' do
      rule 'User agent is required for a session to be created' do
        if RequestStoreUtil.current_request.user_agent.nil?
          level 10
          response_code 401
          fail
        end
      end
    end

    section 'User IP' do
      rule 'has to be created for every session' do
        next unless RequestStoreUtil.current_session&.ip.nil?
        level 5
        response_code 401
        fail
      end
    end

    section 'Active Session' do
      rule 'A user cannot have more than 2 active web sessions' do
        authorized_web_sessions = RequestStoreUtil.current_user.user_sessions.admin_bypass.authorized
        if authorized_web_sessions.size > 2
          authorized_web_sessions[0..-3].each do |session|
            session.update(status_id: UserSessionStatus.id_for(:revoked), message: 'A user cannot have more than 2 active admin user bypasses')
            session.access_token.update(status_id: UserSessionStatus.id_for(:revoked), message: 'A user cannot have more than 2 active admin user bypasses')
          end
        end
      end
    end
  end

end