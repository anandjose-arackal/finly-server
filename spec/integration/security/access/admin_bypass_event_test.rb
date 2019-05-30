require 'rails_helper'
RSpec.describe 'AdminBypass Event' do

  before :all do
    @authorized_ip = random_ip
    @unauthorized_ip = random_ip
    @user_agent = Faker::Internet.user_agent

    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @admin_user = create :admin_user_admin, authorized_ip: @authorized_ip
    @fingerprint = random_fingerprint

    client_properties = RequestHelper::DEFAULT_DATA.deep_dup
    client_properties[:fingerprint] = @fingerprint

    @headers = authentication_headers_for(:web)
    @headers[:HTTP_USER_AGENT] = @user_agent
    @headers[:REMOTE_ADDR] = @authorized_ip

    @user_device_browser = create :user_device_browser, client_properties
    @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
    @user_ip = create :user_ip_verified, ip: @authorized_ip, user: @user1
    @user_agent_client = create :user_agent_client_verified, user: @user1, user_agent: @user_agent


    @doorkeeper_application = create :doorkeeper_application, scopes: 'admin_bypass web'
  end

  describe '> Active UserSession' do
    describe '> Matching IP' do
      describe '> Valid Request' do
        before :all do
          RSpec::Mocks.with_temporary_scope do
            @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id, admin_user_id: @admin_user.id
            @session = create :user_session, access_token: @token, ip: @authorized_ip, admin_user: @admin_user,
                              user_agent: @user_agent, user_device: @device, user_ip: @user_ip, user_agent_client: @user_agent_client,
                              started_at: 5.minutes.ago, last_request_at: 4.minutes.ago, scopes: 'admin_bypass web'
            headers = @headers.deep_dup
            headers['Authorization'] = "Bearer #{@token.token}"


            @before_session_event_count = UserSessionEvent.count
            allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@authorized_ip)
            allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@authorized_ip)
            allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

            @time = Time.now
            allow(Time).to receive(:now).and_return(@time)

            get '/menu_data', headers: headers
          end
        end

        it 'should return 200' do
          expect(response.status).to eq(200)
        end

        it 'should create a UserSessionEvent' do
          expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
          expect(UserSessionEvent.last).to eq(@session.events.last)
        end

        it 'should set the UserSessionEvents status as authorized' do
          expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:authorized))
        end

        it 'should set UserSessions last_request_at to current time' do
          expect(@time - Time.parse(UserSessionEvent.last.user_session.last_request_at.to_s)).to be <= 1.minute
        end
      end

      describe '> Timeout Request' do
        before :all do
          RSpec::Mocks.with_temporary_scope do
            @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id, admin_user_id: @admin_user.id
            @user_ip = create :user_ip, ip: @authorized_ip, user: @user1
            @session = create :user_session, access_token: @token, ip: @authorized_ip,
                              user_device: @device, user_ip: @user_ip, user_agent_client: @user_agent_client,
                              user_agent: @user_agent, admin_user: @admin_user
            headers = @headers.deep_dup
            headers['Authorization'] = "Bearer #{@token.token}"

            @before_session_event_count = UserSessionEvent.count
            allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@authorized_ip)
            allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@authorized_ip)
            allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

            allow(Time).to receive(:now).and_return(Time.now + 31.minutes)
            get '/menu_data', headers: headers
          end
        end

        it 'should return 401' do
          expect(response.status).to eq(401)
        end

        it 'should create a UserSessionEvent' do
          expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
          expect(UserSessionEvent.last).to eq(@session.events.last)
        end

        it 'should set the UserSessionEvents status as revoked' do
          expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:expired))
          expect(UserSessionEvent.last.message).to_not be_nil
        end

        it 'should set the UserSession status as revoked' do
          expect(UserSessionEvent.last.user_session.status_id).to eq(UserSessionStatus.id_for(:expired))
          expect(UserSessionEvent.last.user_session.message).to_not be_nil
        end

        it 'should set the AccessToken status as revoked' do
          expect(UserSessionEvent.last.user_session.access_token.status_id).to eq(UserSessionStatus.id_for(:expired))
          expect(UserSessionEvent.last.user_session.access_token.message).to_not be_nil
        end
      end
    end

    describe '> Mismatching IP' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id, admin_user_id: @admin_user.id
          @session = create :user_session, access_token: @token, ip: @authorized_ip,
                            user_device: @device, user_ip: @user_ip, user_agent_client: @user_agent_client,
                            user_agent: @user_agent, admin_user: @admin_user
          headers = @headers.deep_dup
          headers['Authorization'] = "Bearer #{@token.token}"
          headers[:REMOTE_ADDR] = @unauthorized_ip

          @before_session_event_count = UserSessionEvent.count
          @before_gatekeeper_block_count = GatekeeperBlock.count
          allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@unauthorized_ip)
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@unauthorized_ip)
          allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

          get '/menu_data', headers: headers
        end
      end

      it 'should return 401' do
        expect(response.status).to eq(401)
      end

      it 'should create a GatekeeperBlock entry' do
        expect(@before_gatekeeper_block_count + 1).to eq(GatekeeperBlock.count)
      end

      it 'should create a UserSessionEvent with status as blocked' do
        expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
        expect(UserSessionEvent.last).to eq(@session.events.last)
        expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:blocked))
        expect(UserSessionEvent.last.message).to_not be_nil
      end

      it 'should update UserSession and AccessToken as blocked' do
        expect(UserSessionEvent.last.user_session.status_id).to eq(UserSessionStatus.id_for(:blocked))
        expect(UserSessionEvent.last.user_session.message).to_not be_nil
        expect(UserSessionEvent.last.user_session.access_token.status_id).to eq(UserSessionStatus.id_for(:blocked))
      end

      it 'should not allow the blocked access token to be reused from correct IP' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@authorized_ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@authorized_ip)
        get '/menu_data', headers: @headers
        expect(response.status).to eq(401)
      end
    end
  end

  describe '> Revoked UserSession' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @session = create :user_session, access_token: @token, ip: @authorized_ip, status_id: UserSessionStatus.id_for(:revoked),
                          user_device: @device, user_ip: @user_ip, user_agent_client: @user_agent_client,
                          message: 'Revoke Reason', user_agent: @user_agent, admin_user: @admin_user
        headers = @headers.deep_dup
        headers['Authorization'] = "Bearer #{@token.token}"

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@authorized_ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@authorized_ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        allow(Time).to receive(:now).and_return(Time.now)
        get '/menu_data', headers: headers
      end
    end

    it 'should return 401' do
      expect(response.status).to eq(401)
    end

    it 'should create a UserSessionEvent' do
      expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
      expect(UserSessionEvent.last).to eq(@session.events.last)
    end

    it 'should set the UserSessionEvents status as revoked' do
      expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:revoked))
      expect(UserSessionEvent.last.message).to_not be_nil
      expect(UserSessionEvent.last.message).to eq(UserSessionEvent.last.user_session.message)
    end

  end

  describe '> Non existent user session' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user2.id,
                        admin_user_id: @admin_user.id
        headers = @headers.deep_dup
        headers['Authorization'] = "Bearer #{@token.token}"

        @before_session_event_count = UserSessionEvent.count
        @before_session_count = UserSession.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@authorized_ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@authorized_ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        allow(Time).to receive(:now).and_return(Time.now)
        get '/menu_data', headers: headers
      end
    end

    it 'should return 401' do
      expect(response.status).to eq(401)
    end

    it 'should not create a UserSession' do
      expect(@before_session_count).to eq(UserSession.count)
    end

    it 'should not create a UserSessionEvent' do
      expect(@before_session_event_count).to eq(UserSessionEvent.count)
    end

    it 'should set the AccessToken status as blocked' do
      expect(@token.reload.status_id).to eq(UserSessionStatus.id_for(:blocked))
      expect(@token.message).to_not be_nil
    end
    # With old access tokens > Create a user session
    # With new access token
    # Non existent access tokens
  end

end