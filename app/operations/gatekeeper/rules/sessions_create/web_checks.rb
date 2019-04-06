Gatekeeper::Checker.new 'On Web Authentication' do

  before do
    skip unless RequestStoreUtil.current_session&.client_type == 'UserDeviceBrowser'
    skip if RequestStoreUtil.current_session&.admin_user_id.present?
  end

  premise :after_session_create do
    # todo enable this once frontend is sending the X-Finly-RP headers
    # section 'X-Finly-RP' do
    #   # Web specific checks
    #   rule 'X-Finly-RP is required for all web requests' do
    #     headers = RequestStoreUtil.current_request.headers
    #     next if headers['X-Finly-RP'].present?
    #     response_code 401
    #     fail
    #   end
    #
    #   rule 'Associated device is required for all requests' do
    #     if RequestStoreUtil.current_device.blank?
    #       response_code 401
    #       fail
    #     end
    #   end
    #
    #   section 'If device is available' do
    #     before do
    #       skip if RequestStoreUtil.current_device.nil?
    #     end
    #
    #     [:timestamp, :user_agent, :timezone, :fingerprint,
    #      :language, :browser, :browser_version,
    #      :browser_engine, :browser_engine_version,
    #      :os_name, :os_version].each do |property|
    #       rule "#{property} is required for all web requests" do
    #         web = RequestStoreUtil.current_device.client
    #         next unless web.send(property).blank?
    #         response_code 401
    #         fail
    #       end
    #     end
    #
    #     rule 'Unverified devices need to be verified before proceeding' do
    #       next unless RequestStoreUtil.current_device.status_id == UserDeviceStatus.id_for(:unverified)
    #       require_otp true
    #     end
    #
    #     [:incomplete, :attribute_mismatch, :complete].each do |status_name|
    #       rule "Do not allow login from devices with status #{status_name}" do
    #         web = RequestStoreUtil.current_device
    #         next unless web.status_id == UserDeviceStatus.id_for(status_name)
    #         response_code 401
    #         fail
    #       end
    #     end
    #   end
    #
    # end
    # # todo enable this once frontend is sending the X-Finly-RP headers

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
        next unless RequestStoreUtil.current_session&.user_ip.nil?
        level 10
        response_code 401
        fail
      end

      rule 'Unverified IPs need to be verified before proceeding' do
        next unless RequestStoreUtil.current_session&.user_ip.status_id == UserIpStatus.id_for(:unverified)
        require_otp true
      end
    end

    section 'UserAgentClient' do
      rule 'has to be created for every session' do
        next unless RequestStoreUtil.current_session&.user_agent_client.nil?
        level 10
        response_code 401
        fail
      end

      rule 'Unverified UserAgent Clients need to be verified before proceeding' do
        next unless RequestStoreUtil.current_session&.user_agent_client.status_id == UserIpStatus.id_for(:unverified)
        require_otp true
      end
    end

    section 'Expire' do
      rule 'expires user if password is weak, old passwords and inactivity' do
        RequestStoreUtil.current_user.verify_expiration!(params[:password])
      end
    end

    section 'Active Session' do
      rule 'A user cannot have more than 2 active web sessions' do
        authorized_web_sessions = RequestStoreUtil.current_user.user_sessions.web.authorized.non_admins
        if authorized_web_sessions.size > 2
          authorized_web_sessions[0..-3].each do |session|
            session.update(status_id: UserSessionStatus.id_for(:revoked), message: 'A user cannot have more than 2 active web sessions')
            session.access_token.update(status_id: UserSessionStatus.id_for(:revoked), message: 'A user cannot have more than 2 active web sessions')
          end
        end
      end
    end
  end

end