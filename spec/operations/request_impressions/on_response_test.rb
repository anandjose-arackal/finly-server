require 'rails_helper'

RSpec.describe 'RequestImpressions::OnResponse' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @ip = Faker::Internet.ip_v4_address
    @ip_type = 'ipv4'

    @user_device_browser = create :user_device_browser
    @doorkeeper_application = create :doorkeeper_application
    @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
    @user_ip = create :user_ip, ip: @ip, user: @user1
    @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
    @request_impression = create :request_impression
  end

  def test_attribute_value_for(key, value)

  end

  describe '> Correct Params' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(RequestStoreUtil).to receive(:request_impression).and_return(@request_impression)
        @user_session = create :user_session, access_token: @token,
                               status_id: UserSessionStatus.id_for(:authorized), ip: @ip,
                               user_device_id: @device.id, user_ip_id: @user_ip.id

        @duration = 1000
        @response = double({status: 200})
        allow(RequestStoreUtil).to receive(:current_session).and_return(@user_session)
        allow(RequestStoreUtil).to receive(:current_user).and_return(@user1)
        allow(RequestStoreUtil).to receive(:current_company).and_return(@company)
        @result = RequestImpressions::OnResponse.(@duration, @response, {user: @user1, username: @username, controller: @controller, action: @action})
        @request_impression.reload
      end
    end

    it 'should have all all attributes set' do
      expect(@request_impression.response_code).to eq(200)
      expect(@request_impression.response_time).to eq(1000)
      expect(@request_impression.user_id).to eq(@user1.id)
      expect(@request_impression.company_id).to eq(@user1.company_id)
      expect(@request_impression.user_session_id).to eq(@user_session.id)
      expect(@request_impression.access_token_id).to eq(@user_session.access_token_id)
      expect(@request_impression.user_ip_id).to eq(@user_ip.id)
      expect(@request_impression.user_device_id).to eq(@device.id)
      expect(@request_impression.blocked).to eq(nil)
      expect(@request_impression.blocked_by).to be_nil
      expect(@request_impression.block_reason).to be_nil
    end
  end

  describe '> Gatekeeper Block' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        @block_message = 'block message'
        @user_session = create :user_session, access_token: @token,
                               status_id: UserSessionStatus.id_for(:blocked), message: @block_message, ip: @ip,
                               user_device_id: @device.id, user_ip_id: @user_ip.id

        allow(RequestStoreUtil).to receive(:request_impression).and_return(@request_impression)
        @duration = 1000
        @response = double({status: 200})
        allow(RequestStoreUtil).to receive(:current_session).and_return(@user_session)
        allow(RequestStoreUtil).to receive(:current_user).and_return(@user1)
        allow(RequestStoreUtil).to receive(:current_company).and_return(@company)
        @result = RequestImpressions::OnResponse.(@duration, @response, {user: @user1, username: @username, controller: @controller, action: @action})
        @request_impression.reload
      end
    end

    it 'should have all all attributes set' do
      expect(@request_impression.response_code).to eq(200)
      expect(@request_impression.response_time).to eq(1000)
      expect(@request_impression.user_id).to eq(@user1.id)
      expect(@request_impression.company_id).to eq(@user1.company_id)
      expect(@request_impression.user_session_id).to eq(@user_session.id)
      expect(@request_impression.access_token_id).to eq(@user_session.access_token_id)
      expect(@request_impression.user_ip_id).to eq(@user_ip.id)
      expect(@request_impression.user_device_id).to eq(@device.id)
      expect(@request_impression.blocked).to eq(true)
      expect(@request_impression.blocked_by).to eq('gatekeeper')
      expect(@request_impression.block_reason).to eq(@block_message)
    end
  end

  describe '> Rack Attack block' do

  end

end
