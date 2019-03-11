Gatekeeper::Checker.new 'On Web Authentication' do

  before do
    skip unless RequestStoreUtil.current_device&.client_type == 'UserDeviceBrowser'
  end

  premise :after_session_create do
    # todo un-skip once frontend is implemented
    section 'X-Finly-RP' do
      # Web specific checks
      rule 'X-Finly-RP is required for all web requests' do
        headers = RequestStoreUtil.current_request.headers
        next if headers['X-Finly-RP'].present?
        response_code 401
        fail
      end

      rule 'Associated device is required for all requests' do
        if RequestStoreUtil.current_device.blank?
          response_code 401
          fail
        end
      end

      # # todo Temporary as device is not available at the moment because of lack of frontend dev
      # rule 'User agent is required for a session to be created' do
      #   if RequestStoreUtil.current_request.user_agent.nil?
      #     response 401
      #     fail
      #   end
      # end
      # # todo Temporary as device is not available at the moment because of lack of frontend dev

      section 'If device is available' do
        before do
          skip if RequestStoreUtil.current_device.nil?
        end

        [:timestamp, :user_agent, :timezone, :fingerprint,
         :language, :browser, :browser_version,
         :browser_engine, :browser_engine_version,
         :os_name, :os_version].each do |property|
          rule "#{property} is required for all web requests" do
            web = RequestStoreUtil.current_device.client
            next unless web.send(property).blank?
            response_code 401
            fail
          end
        end
      end
    end

    section 'Active Session' do
      rule 'A user cannot have more than 2 active web sessions' do
        authorized_web_sessions = RequestStoreUtil.current_user.user_sessions.web.authorized
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