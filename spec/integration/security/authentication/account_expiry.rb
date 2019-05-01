require 'rails_helper'
RSpec.describe 'UserAuthentication > Expiry' do

  before :all do
    @password = 'FW1g$18j0t!k19TJ'
    @company = create :company
    @user = create :em_user, company: @company, last_activity_at: DateTime.now, password_changed_at: DateTime.now, otp_verified: true
    @user.update(password: @password, password_confirmation: @password)
    @doorkeeper_application = create :doorkeeper_application
    @user_device_browser = create :user_device_browser
    @doorkeeper_application = create :doorkeeper_application
    @ip = random_ip
    @device = create :user_device, client: @user_device_browser, company: @company, user: @user
    @user_ip = create :user_ip, ip: @ip, user: @user
    @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user.id
    @request_impression = create :request_impression
    @user_agent = Faker::Internet.user_agent

    @headers = authentication_headers_for(:web)
    @headers[:REMOTE_ADDR] = @ip
    @headers[:HTTP_USER_AGENT] = @user_agent
  end

  describe '> Expired User' do

    before :all do
      RSpec::Mocks.with_temporary_scope do
        @user.expire!
        expect do
          post '/oauth/token.json', params: {
              email: @user.email,
              password: @password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
        end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1).and \
        change {RequestImpression.count}.by(1)

        @body = JSON.parse response.body
        @token_value = @body&.dig('data', 'access_token')
        @session = UserSession.last
      end
    end

    # todo should end all active sessions
    it 'should clear all old sessions' do
      # expect(@user.user_sessions.count).to eq(3)
      # expect(@user.user_sessions.authorized.count).to eq(1)
      # expect(@user.access_tokens.where(status_id: UserSessionStatus.id_for(:authorized).count).to eq(0))
    end

    it 'should give a 200 response' do
      expect(response).to have_http_status(:ok)
    end

    it 'should send OTP verified as false' do
      expect(@body['otp_verified']).to_not be_truthy
    end

    it 'should send expired as true' do
      expect(@body['expired']).to be_truthy
    end

    it 'should set user as expired' do
      expect(@user.expired?).to be_truthy
    end

    describe '> Access Limits' do
      it 'should allow send_otp endpoint' do
        # Prevent OTP from being sent
        allow(User::Verification::Otp::Create).to receive(:call).and_return(BaseOperation::BasePresenter::SuccessPresenter.new(@user, {}, nil))

        expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
        headers = @headers.deep_dup
        headers['Authorization'] = "Bearer #{@token_value}"

        post '/otp/resend.json', headers: headers
        expect(response).to have_http_status(:ok)
        expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
      end

      it 'should allow verify otp endpoint' do
        expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
        headers = @headers.deep_dup
        headers['Authorization'] = "Bearer #{@token_value}"

        post '/otp/verify.json', headers: headers, params: {mobile_number: @user.mobile_number, verification_code: @user.otp}
        expect(response).to have_http_status(:ok)
        expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
      end

      # Todo as devise is using a different controller, not implementing this at the moment
      # it 'should not allow set passwords endpoint unless otp_verified' do
      #   expect(@user.expired?).to be_truthy
      #   expect(@user.otp_verified).to_not be_truthy
      #   expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
      #   headers = {'Authorization': "Bearer #{@token_value}", REMOTE_ADDR: @ip, HTTP_USER_AGENT: @user_agent}
      #   @new_password = 'FW1g$18j0t!k19TRe'
      #   post '/users/password.json', headers: headers, params: {password: @new_password, password_confirmation: @new_password}
      #   expect(response).to have_http_status(:unauthorized)
      #   expect(@session.status_id).to eq(UserSessionStatus.id_for(:blocked))
      # end

      it 'should not allow any other endpoint' do
        @session.update(status_id: UserSessionStatus.id_for(:authorized))
        expect(@session.status_id).to eq(UserSessionStatus.id_for(:authorized))
        headers = @headers.deep_dup
        headers['Authorization'] = "Bearer #{@token_value}"

        get '/menu_data.json', headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(@session.reload.message).to eq('User is expired')
        expect(@session.status_id).to eq(UserSessionStatus.id_for(:blocked))
      end
    end
  end

  describe '> User with weak passwords' do
    it 'should mark the user as expired' do
      weak_password = '12345678'
      @user.assign_attributes(
          {
              password: weak_password,
              password_confirmation: weak_password,
              last_activity_at: DateTime,
              password_changed_at: DateTime.now,
              expired_at: nil
          }
      )
      expect(@user.save(validate: false)).to be_truthy
      expect(@user.expired?).to be_falsey

      expect do
        post '/oauth/token.json', params: {
            email: @user.email,
            password: weak_password,
            otp_verified: true,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1).and \
        change {RequestImpression.count}.by(1)

      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
      @session = UserSession.last

      expect(@token_value).to_not be_nil
      expect(@body['expired']).to be_truthy
      expect(@body['otp_verified']).to be_falsey
      expect(@user.reload.expired?).to be_truthy
    end
  end

  describe '> User with old passwords' do
    it 'should mark the user as expired' do
      password = 'FW1g$18j0t!k19TJjL'
      @user.assign_attributes(
          {
              password: password,
              password_confirmation: password,
              last_activity_at: DateTime,
              password_changed_at: DateTime.now,
              expired_at: nil
          }
      )
      expect(@user.save(validate: false)).to be_truthy
      expect(@user.expired?).to be_falsey

      @user.update(password_changed_at: 91.days.ago)

      expect do
        post '/oauth/token.json', params: {
            email: @user.email,
            password: password,
            otp_verified: true,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1).and \
        change {RequestImpression.count}.by(1)

      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
      @session = UserSession.last

      expect(@token_value).to_not be_nil
      expect(@body['expired']).to be_truthy
      expect(@body['otp_verified']).to be_falsey
      expect(@user.reload.expired?).to be_truthy
    end
  end

  describe '> Users with no activity' do
    it 'should mark the user as expired' do
      password = 'FW1g$18j0t!t19TJjL'
      @user.assign_attributes(
          {
              password: password,
              password_confirmation: password,
              last_activity_at: DateTime,
              password_changed_at: DateTime.now,
              expired_at: nil
          }
      )
      expect(@user.save(validate: false)).to be_truthy
      expect(@user.expired?).to be_falsey

      @user.update(last_activity_at: 91.days.ago)

      expect do
        post '/oauth/token.json', params: {
            email: @user.email,
            otp_verified: true,
            password: password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1).and \
        change {RequestImpression.count}.by(1)

      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
      @session = UserSession.last

      expect(@token_value).to_not be_nil
      expect(@body['expired']).to be_truthy
      expect(@body['otp_verified']).to be_falsey
      expect(@user.reload.expired?).to be_truthy
    end
  end

  describe '> Active User' do
    it 'should update users last_activity_at' do
      password = 'FW1g$18jRt!t19TJjL'
      old_last_activity = 10.minutes.ago
      @user.assign_attributes(
          {
              password: password,
              otp_verified: true,
              password_confirmation: password,
              last_activity_at: old_last_activity,
              password_changed_at: DateTime.now,
              expired_at: nil
          }
      )
      expect(@user.save(validate: false)).to be_truthy
      expect(@user.expired?).to be_falsey
      expect(@user.last_activity_at).to_not eq(old_last_activity)
      expect(@user.valid_password?(password)).to be_truthy

      allow_any_instance_of(UserDevice).to receive(:status_id).and_return(UserDeviceStatus.id_for(:verified))
      allow_any_instance_of(UserIp).to receive(:status_id).and_return(UserIpStatus.id_for(:verified))
      allow_any_instance_of(UserAgentClient).to receive(:status_id).and_return(UserAgentClientStatus.id_for(:verified))

      Rack::Attack.cache.prefix = 'rack::attack::clear'

      expect do
        post '/oauth/token.json', params: {
            email: @user.email,
            password: password,
            client_id: @doorkeeper_application.uid,
            client_secret: @doorkeeper_application.secret
        }, headers: @headers
      end.to \
        change {GatekeeperBlock.count}.by(0).and \
        change {Doorkeeper::AccessToken.count}.by(1).and \
        change {UserSession.count}.by(1).and \
        change {UserSessionEvent.count}.by(1).and \
        change {RequestImpression.count}.by(1)

      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
      @session = UserSession.last

      expect(@token_value).to_not be_nil
      expect(@body['expired']).to be_falsey
      expect(@body['otp_verified']).to be_truthy
      expect(@user.reload.expired?).to be_falsey
      expect(@user.last_activity_at).to_not eq(old_last_activity)

      Rack::Attack.cache.prefix = 'rack::attack'
    end
  end


end