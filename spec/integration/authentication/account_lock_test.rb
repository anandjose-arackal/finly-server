require 'rails_helper'
RSpec.describe 'AccountLock' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @doorkeeper_application = create :doorkeeper_application

    @correct_password = 'password'
    @wrong_password = 'wrong_password'

    @headers = authentication_headers_for(:web)
  end

  describe '> Unlocked account' do
    it 'should Lock account on more than 5 failed attempts' do
      expect(@user1.locked_at).to be_nil
      expect(@user1.failed_attempts).to eq(0)

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
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

        expect(response.status).to eq(401)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('invalid_grant')
        expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
      end

      expect(@user1.reload.locked_at).to be_nil
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
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('invalid_grant')
      expect(body['error_description']).to eq('The email / mobile or password you entered is incorrect')
      expect(@user1.reload.locked_at).to_not be_nil
    end
  end

  describe '> Locked accounts' do
    it 'should automatically unlock after 30 minutes' do
      time = Time.now

      expect(@user2.reload.locked_at).to be_nil
      @user2.update(locked_at: time)
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
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1)

      expect(response.status).to eq(401)
      expect(@user2.reload.locked_at).to_not be_nil

      allow(Time).to receive(:now).and_return(time + 31.minutes)
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