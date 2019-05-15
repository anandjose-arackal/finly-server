require 'rails_helper'
RSpec.describe 'AccountLock' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @doorkeeper_application = create :doorkeeper_application

    @correct_password = 'FW1g$18j0t!k2'
    @wrong_password = 'wrong_password'

    @headers = authentication_headers_for(:web)
  end

  describe '> Unlocked account' do
    it 'should Lock account on more than 5 failed attempts' do
      expect(@user1.locked_at).to be_nil
      expect(@user1.failed_attempts).to eq(0)
      @user_agent = Faker::Internet.user_agent
      allow_any_instance_of(SecurityPolicy::Manager).to receive(:account_lock).and_return(double({within_timeframe: 30.minutes, max_attempts: 4, locking_period: 30.minutes}))
      allow_any_instance_of(SecurityPolicy::Manager).to receive(:browser_client).and_return(double({concurrent_logins: 2}))

      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)

      4.times.each do
        expect do
          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @wrong_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
        end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserAuthFailure.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

        expect(response.status).to eq(401)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('invalid_grant')
        expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
      end

      expect(@user1.reload.locked_at).to be_nil
      expect(@user1.user_auth_failures.within_time(Time.now - 30.minutes).size).to eq(4)
      expect do
        post '/oauth/token.json', params: {
            email: @user1.email,
            password: @wrong_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(1).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserAuthFailure.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
      expect(@user1.reload.locked_at).to_not be_nil
      expect(UserAuthFailure.last.locked).to be_truthy
    end
  end

  describe '> Locked accounts' do
    it 'should automatically unlock after 30 minutes' do
      time = Time.now
      @user_agent = Faker::Internet.user_agent

      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(@user_agent)
      allow_any_instance_of(SecurityPolicy::Manager).to receive(:account_lock).and_return(double({within_timeframe: 30.minutes, max_attempts: 4, locking_period: 30.minutes}))
      allow_any_instance_of(SecurityPolicy::Manager).to receive(:browser_client).and_return(double({concurrent_logins: 2}))

      expect(@user2.reload.locked_at).to be_nil
      @user2.update(locked_at: time, password_changed_at: nil)
      expect(@user2.reload.locked_at).to_not be_nil

      expect do
        post '/oauth/token.json', params: {
            email: @user2.email,
            password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(1).and \
        change {Doorkeeper::AccessToken.count}.by(0).and \
        change {UserAuthFailure.count}.by(0).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      expect(@user2.reload.locked_at).to_not be_nil

      allow(Time).to receive(:now).and_return(Time.now + 35.minutes)

      expect do
        post '/oauth/token.json', params: {
            email: @user2.email,
            password: @correct_password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret,
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(200)

      expect(@user2.reload.locked_at).to be_nil
    end
  end

end