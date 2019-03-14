require 'rails_helper'
RSpec.describe 'UserAuthentication > Password' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @doorkeeper_application = create :doorkeeper_application

    @correct_password = 'password'
    @wrong_password = 'wrong_password'

    @headers = authentication_headers_for(:web)
  end

  describe '> Invalid Password' do
    it 'should throw 401 unless correct username is entered' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

      expect do
        post '/oauth/token.json', params: {
            email: 'asd',
            password: @correct_password,
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

    it 'should throw 401 unless correct password is entered' do
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
  end

  describe '> Valid Password' do
    it 'should return 200 with tokens when correct username and password is entered' do
      @ip = random_ip
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(@ip)
      allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

      expect do
        post '/oauth/token.json', params: {
            email: @user2.email,
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
      body = JSON.parse(response.body)
      expect(body&.dig('data', 'access_token')).to_not be_nil
      expect(body&.dig('data', 'refresh_token')).to be_nil

      session = UserSession.last
      token = Doorkeeper::AccessToken.last
      expect(session.access_token_id).to eq(token.id)
      expect(session.ip).to eq(@ip)
      expect(session.user_device).to_not be_nil
      expect(session.user_device.client.class).to be(UserDeviceBrowser)

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