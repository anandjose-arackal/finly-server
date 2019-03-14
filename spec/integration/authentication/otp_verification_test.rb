require 'rails_helper'
RSpec.describe 'OtpVerification' do

  describe '> Browser' do
    before :all do
      @company = create :company
      @user1 = create :em_user, company: @company
      @user2 = create :em_user, company: @company

      @doorkeeper_application = create :doorkeeper_application

      @correct_password = 'password'

      @headers = authentication_headers_for(:web)
    end

    describe '> Unverified UserDevices' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @user_device_browser = create :user_device_browser
          @device = create :user_device, client: @user_device_browser, company: @company, user: @user1, status_id: UserDeviceStatus.id_for(:unverified)
          @ip = '106.51.25.1'
          @ip_addr = create :user_ip, ip: @ip, user_id: @user1.id, status_id: UserIpStatus.id_for(:verified)

          allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({success?: true, device: @device}))
          allow(UserIps::FindOrCreate).to receive(:call).and_return(double({success?: true, ip: @ip_addr}))
          allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
          @response = response
          @body = JSON.parse(response.body)
        end
      end
      it 'should give 200 response' do
        expect(@response.status).to eq(200)
      end

      it 'should not send access token' do
        expect(@body&.dig('data', 'access_token')).to_not be_nil
      end

      it 'should require OTP' do
        expect(@body&.dig('otp_verified')).to eq(false)
      end
    end

    describe '> Verified UserDevices' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @user_device_browser = create :user_device_browser
          @device = create :user_device, client: @user_device_browser, company: @company, user: @user1, status_id: UserDeviceStatus.id_for(:verified)
          @ip = '106.51.25.1'
          @ip_addr = create :user_ip, ip: @ip, user_id: @user1.id, status_id: UserIpStatus.id_for(:verified)

          allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({success?: true, device: @device}))
          allow(UserIps::FindOrCreate).to receive(:call).and_return(double({success?: true, ip: @ip_addr}))
          allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
          @response = response
          @body = JSON.parse(response.body)
        end
      end
      it 'should give 200 response' do
        expect(@response.status).to eq(200)
      end

      it 'should send access token' do
        expect(@body&.dig('data', 'access_token')).to_not be_nil
      end

      it 'should not require OTP' do
        expect(@body&.dig('otp_verified')).to eq(true)
      end
    end

    describe '> Unverified UserIPs' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @user_device_browser = create :user_device_browser
          @device = create :user_device, client: @user_device_browser, company: @company, user: @user1, status_id: UserDeviceStatus.id_for(:verified)
          @ip = '106.51.25.1'
          @ip_addr = create :user_ip, ip: @ip, user_id: @user1.id, status_id: UserIpStatus.id_for(:unverified)

          allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({success?: true, device: @device}))
          allow(UserIps::FindOrCreate).to receive(:call).and_return(double({success?: true, ip: @ip_addr}))
          allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
          @response = response
          @body = JSON.parse(response.body)
        end
      end
      it 'should give 200 response' do
        expect(@response.status).to eq(200)
      end

      it 'should not send access token' do
        expect(@body&.dig('data', 'access_token')).to_not be_nil
      end

      it 'should require OTP' do
        expect(@body&.dig('otp_verified')).to eq(false)
      end
    end

    describe '> Verified UserIPs' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @user_device_browser = create :user_device_browser
          @device = create :user_device, client: @user_device_browser, company: @company, user: @user1, status_id: UserDeviceStatus.id_for(:verified)
          @ip = '106.51.25.1'
          @ip_addr = create :user_ip, ip: @ip, user_id: @user1.id, status_id: UserIpStatus.id_for(:verified)

          allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({success?: true, device: @device}))
          allow(UserIps::FindOrCreate).to receive(:call).and_return(double({success?: true, ip: @ip_addr}))
          allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(Faker::Internet.user_agent)

          post '/oauth/token.json', params: {
              email: @user1.email,
              password: @correct_password,
              client_id: @doorkeeper_application.uid,
              client_secret: @doorkeeper_application.secret
          }, headers: @headers
          @response = response
          @body = JSON.parse(response.body)
        end
      end
      it 'should give 200 response' do
        expect(@response.status).to eq(200)
      end

      it 'should send access token' do
        expect(@body&.dig('data', 'access_token')).to_not be_nil
      end

      it 'should not require OTP' do
        expect(@body&.dig('otp_verified')).to eq(true)
      end
    end
  end

end