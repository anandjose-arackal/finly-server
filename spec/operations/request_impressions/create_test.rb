require 'rails_helper'

RSpec.describe 'RequestImpressions::Create' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @ip = Faker::Internet.ip_v4_address
    @ip_type = 'ipv4'
  end

  describe '> Correct Params' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        @before_request_impression_count = RequestImpression.count

        headers = authentication_headers_for(:web)
        @controller = 'oauth/token'
        @action = 'create'
        @path = 'oauth/login'
        @user_agent = Faker::Internet.user_agent
        @referrer = 'www.google.com'
        @username = @user1.email

        request = double({referer: @referrer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post', user_agent: @user_agent})

        @result = RequestImpressions::Create.(request, {user: @user1, username: @username, controller: @controller, action: @action})
      end
    end

    it 'should be success' do
      expect(@result.success?).to eq(true)
    end

    it 'should create a new RequestImpression for the user' do
      expect(@before_request_impression_count + 1).to eq(RequestImpression.count)
      expect(@result.request_impression).to_not be_nil
    end

    it 'should have attributes not set as null' do
      {
          ip: @ip,
          ip_type: 'ipv4',
          referrer: @referrer,
          path: @path,
          controller: @controller,
          action: @action,
          user_agent: @user_agent,
          username: @username
      }.each do |attr, value|
        expect(@result.request_impression.send(attr)).to eq(value)
      end
    end


  end

end
