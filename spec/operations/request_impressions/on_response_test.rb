require 'rails_helper'

RSpec.describe 'RequestImpressions::OnResponse' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @ip = Faker::Internet.ip_v4_address
    @ip_type = 'ipv4'

    @doorkeeper_application = create :doorkeeper_application
    @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
    @user_ip = create :user_ip, ip: @ip, user: @user1
    @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
    @user_session = create :user_session, access_token: @token,
                           status_id: UserSessionStatus.id_for(:authorized), ip: @ip,
                           user_device_id: @device.id, user_ip_id: @user_ip.id
    @request_impression = create :request_impression
  end

  describe '> Correct Params' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(RequestStoreUtil).to receive(:request_impression).and_return(@request_impression)
        @duration = 1000
        @response = double({})
        @result = RequestImpressions::OnResponse.(@duration, {user: @user1, username: @username, controller: @controller, action: @action})
      end

      
    end
  end

end
