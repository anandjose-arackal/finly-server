require 'rails_helper'
RSpec.describe 'UserSession#LastRequestAt update test' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company, expired_at: nil, otp_verified: true
    @user2 = create :em_user, company: @company, expired_at: nil, otp_verified: true
    @admin_user = create :admin_user_admin
    @user_agent = Faker::Internet.user_agent

    @ip = random_ip

    @user_device_browser = create :user_device_browser
    @doorkeeper_application = create :doorkeeper_application
  end

  describe 'Update-able request' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@time.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'AdminUser Access' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_unverified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_unverified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_unverified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 5.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device, admin_user_id: @admin_user.id

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@time.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Locked session' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device, status_id: UserSessionStatus.id_for(:blocked)

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Notifications Unread' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device, status_id: UserSessionStatus.id_for(:blocked)

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Expired User' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @user1.update(expired_at: DateTime.now)
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device, status_id: UserSessionStatus.id_for(:blocked)

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Unverified Device' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_unverified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Unverified UserIP' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_unverified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_verified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

  describe 'Unverified UserAgentClient' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @device = create :user_device_verified, client: @user_device_browser, company: @company, user: @user1
        @user_ip = create :user_ip_verified, ip: @ip, user: @user1
        @user_agent_client = create :user_agent_client_unverified, user_id: @user1.id, user_agent: @user_agent

        @headers = {'Authorization': "Bearer #{@token.token}"}
        @old_last_request_at = DateTime.now - 10.minutes

        @session = create :user_session, access_token: @token, ip: @ip, user_ip: @user_ip,
                          started_at: 15.minutes.ago, last_request_at: @old_last_request_at, user_agent: @user_agent,
                          user_agent_client: @user_agent_client, user_device: @device

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

        @time = DateTime.now
        allow(DateTime).to receive(:now).and_return(@time)

        get '/menu_data', headers: @headers
      end
    end

    it 'should update last_updated_at of the user' do
      expect(@session.reload.last_request_at.strftime("%I:%M %p, %d %b %Y")).to eq(@old_last_request_at.strftime("%I:%M %p, %d %b %Y"))
    end
  end

end