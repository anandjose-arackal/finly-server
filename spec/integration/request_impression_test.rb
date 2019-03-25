require 'rails_helper'
RSpec.describe 'RequestImpression Test' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @ip = '1.2.3.4'

    @user_device_browser = create :user_device_browser
    @doorkeeper_application = create :doorkeeper_application
    @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
    @user_ip = create :user_ip, ip: @ip, user: @user1
    @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
    @user_session = create :user_session, access_token: @token,
                           status_id: UserSessionStatus.id_for(:authorized), ip: @ip,
                           user_device_id: @device.id, user_ip_id: @user_ip.id
  end

  describe '> Without Block' do
    describe '> Authenticated' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @before_impression_count = RequestImpression.count
          allow(UserSession).to receive(:find_by_access_token_id).and_return(@user_session)

          get '/features_subscribed', headers: {'Authorization': "Bearer #{@token.token}", REMOTE_ADDR: @ip}
          @request_impression = RequestImpression.last
        end
      end

      it 'should have token as authorized' do
        expect(@token.status_id).to eq(UserSessionStatus.id_for(:authorized))
      end

      it 'should return 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'should create a new RequestImpression' do
        expect(@before_impression_count + 1).to eq(RequestImpression.count)
      end

      it 'should have UserSession, UserDevice, Token and UserIp associated' do
        expect(@request_impression.user_device_id).to eq(@device.id)
        expect(@request_impression.user_session_id).to eq(@user_session.id)
        expect(@request_impression.access_token_id).to eq(@token.id)
        expect(@request_impression.user_ip_id).to eq(@user_session.user_ip_id)
      end

      it 'should have response time and response code' do
        expect(@request_impression.response_code).to eq(200)
        expect(@request_impression.response_time).to_not be_nil
      end

      it 'should have user and company set' do
        expect(@request_impression.user_id).to eq(@user1.id)
        expect(@request_impression.company_id).to eq(@user1.company_id)
      end

    end
  end

  describe '> Gatekeeper Block' do

  end

  describe '> Rack::Attack Block' do

  end

end