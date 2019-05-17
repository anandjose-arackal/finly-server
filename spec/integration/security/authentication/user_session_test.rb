require 'rails_helper'
RSpec.describe 'UserSession' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @doorkeeper_application = create :doorkeeper_application

    @correct_password = 'FW1g$18j0t!k2'
    @wrong_password = 'wrong_password'

    @headers = authentication_headers_for(:web)
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

  describe '> Create' do
    describe '> Success' do
      it 'should not allow more than 2 concurrent sessions' do
        sessions = []
        expect(@user1.user_sessions.count).to eq(0)

        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)
        allow_any_instance_of(SecurityPolicy::Manager).to receive(:browser_client).and_return(double(concurrent_logins: 2))

        2.times.each do
          expect do
            post '/oauth/token.json', params: {
                email: @user1.email,
                password: @correct_password,
                client_id: @doorkeeper_application.uid,
                client_secret: @doorkeeper_application.secret
            }, headers: @headers
          end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

          expect(response.status).to eq(200)
          session = @user1.user_sessions.last
          sessions << session
          expect(session.status_id).to eq(UserSessionStatus.id_for(:authorized))
          expect(session.access_token.status_id).to eq(UserSessionStatus.id_for(:authorized))
        end

        expect do
          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
        end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

        expect(response.status).to eq(200)
        session = @user1.user_sessions.last
        expect(session.status_id).to eq(UserSessionStatus.id_for(:authorized))
        expect(session.access_token.status_id).to eq(UserSessionStatus.id_for(:authorized))
        expect(sessions.first.reload.status_id).to eq(UserSessionStatus.id_for(:revoked))
        expect(sessions.first.reload.message).to_not be_nil
        expect(sessions.first.access_token.status_id).to eq(UserSessionStatus.id_for(:revoked))
        expect(sessions.first.access_token.reload.message).to_not be_nil
        expect(sessions.second.reload.status_id).to eq(UserSessionStatus.id_for(:authorized))
        expect(sessions.second.access_token.reload.status_id).to eq(UserSessionStatus.id_for(:authorized))
      end
    end

    describe '> Failure' do
      it 'should throw 401' do
        @issue_string = 'Issue issue'
        allow(UserSessions::Create).to receive(:call).and_return(double({success?: false, messages: {error: [@issue_string]}}))
        allow_any_instance_of(SecurityPolicy::Manager).to receive(:browser_client).and_return(double(concurrent_logins: 2))

        expect do
          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
        end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1)

        expect(response.status).to eq(401)
      end
    end
  end

end