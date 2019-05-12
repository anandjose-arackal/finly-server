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

        @path = '/lookup.json'
        @user_agent = Faker::Internet.user_agent
        @referrer = 'www.google.com'
        @username = @user1.email

        request = {
            referrer: @referrer,
            ip: @ip,
            landing_page: @original_url,
            path: @path,
            http_method: 'post',
            user_agent: @user_agent,
            block_reason: :throttle,
            response_code: 429
        }

        @result = RequestImpressions::OnRackAttackBlock.(request, {email_mobile: @username})
        @request_impression = RequestImpression.last
      end
    end

    it 'should be success' do
      expect(@result.success?).to eq(true)
    end

    it 'should create a new RequestImpression for the user' do
      expect(@before_request_impression_count + 1).to eq(RequestImpression.count)
      expect(@request_impression).to_not be_nil
    end

    it 'should have attributes not set as null' do
      expect(@request_impression.ip).to eq(@ip)
      expect(@request_impression.ip_type).to eq('ipv4')
      expect(@request_impression.referrer).to eq(@referrer)
      expect(@request_impression.path).to eq(@path)
      expect(@request_impression.user_agent).to eq(@user_agent)
      expect(@request_impression.username).to eq(@username)
      expect(@request_impression.blocked).to eq(true)
      expect(@request_impression.blocked_by).to eq('rack_attack')
      expect(@request_impression.block_reason).to eq('throttle')
    end

  end

end
