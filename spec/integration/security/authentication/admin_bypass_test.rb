require 'rails_helper'
RSpec.describe 'UserAuthentication > Password' do

  before :all do
    @company = create :company
    @correct_password = 'password'
    @wrong_password = 'wrong_password'

    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @ip = random_ip
    @user_agent = Faker::Internet.user_agent
    @admin_user = create :admin_user_admin, authorized_ip: @ip, password: @correct_password, password_confirmation: @correct_password
    @admin_user.set_master_password(@correct_password)

    @doorkeeper_application = create :doorkeeper_application, scopes: 'admin_bypass web'
    @headers = authentication_headers_for(:web)

    @reason = 'Reason goes here'
    @reason_details = 'Reason details goes here'

    @headers = authentication_headers_for(:web)
    @headers[:REMOTE_ADDR] = @ip
    @headers[:HTTP_USER_AGENT] = @user_agent
  end

  before :each do
    setup_rack_attack_cache_store
    avoid_test_overlaps_in_cache
  end

  def setup_rack_attack_cache_store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  def avoid_test_overlaps_in_cache
    Rails.cache.clear
  end

  describe '> Unauthorized domain' do
    it 'should throw a 401' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('www.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(1).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(GatekeeperBlock.last.rule.include?('Only admin.finly.io can be used for accessing admin panel')).to be_truthy

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end
  end

  describe '> Unauthorized IP' do
    it 'should throw 401' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      headers = @headers.deep_dup
      headers[:REMOTE_ADDR] = '12.3.4.5'

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: headers
      end.to \
        change {GatekeeperBlock.count}.by(1).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(GatekeeperBlock.last.rule.include?('Only authorized IP can be used for accessing admin panel')).to be_truthy

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end
  end

  describe '> Invalid Admin Password' do
    it 'should throw 401 unless correct username is entered' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: 'asd@bsd.com',
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end

    it 'should throw 401 unless correct admin password is entered' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @wrong_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end

    it 'should throw 401 unless correct master password is entered' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @wrong_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end
  end

  describe '> Without reason' do
    it 'should throw a 401 without reason' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: nil,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end

    it 'should throw a 401 without reason details' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: nil
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
    end
  end

  describe '> Valid Password' do
    it 'should return 200 with tokens when correct username and password is entered' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
      allow_any_instance_of(ActionDispatch::Request).to receive(:domain).and_return('admin.finly.io')
      allow(Finly::SecureStorage::Connector).to receive(:read).and_return([@admin_user.email])

      expect do
        post '/admin/oauth/bypass_token.json', params: {
            username: @admin_user.email,
            password: @correct_password,
            master_password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
            for_user_id: @user1.id,
            reason: @reason,
            reason_details: @reason_details
        }, headers: @headers
      end.to \
      change {GatekeeperBlock.count}.by(0).and \
      change {Doorkeeper::AccessToken.count}.by(1).and \
      change {UserSession.count}.by(1).and \
      change {UserSessionEvent.count}.by(1)
      expect(response.status).to eq(200)
      expect(UserSession.last.admin_access_reason).to eq(@reason)
      expect(UserSession.last.admin_access_reason_details).to eq(@reason_details)

      body = JSON.parse(response.body)
      expect(body&.dig('data', 'access_token')).to_not be_nil
      expect(body&.dig('data', 'refresh_token')).to be_nil

      session = UserSession.last
      token = Doorkeeper::AccessToken.last
      expect(session.access_token_id).to eq(token.id)
      expect(session.ip).to eq(@ip)
      expect(session.user_ip).to be_nil
      expect(session.user_agent_client).to be_nil
      expect(session.user_device).to be_nil
      expect(session.scopes).to eq('admin_bypass web')

      body = JSON.parse(response.body)
      expect(body&.dig('success')).to eq(true)
      expect(body&.dig('data', 'access_token')).to_not be_nil
      expect(body&.dig('data', 'refresh_token')).to be_nil
      expect(body&.dig('data', 'token_type')).to be_nil
      expect(body&.dig('data', 'expires_in')).to be_nil
      expect(body&.dig('data', 'user', 'id')).to_not be_nil
    end
  end

end