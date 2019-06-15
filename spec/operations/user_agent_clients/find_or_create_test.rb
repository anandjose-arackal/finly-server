require 'rails_helper'

RSpec.describe 'UserAgentClients::FindOrCreate' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @ua = Faker::Internet.user_agent
  end

  describe '> Correct Params' do
    describe '> New IP' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @before_ua_count = UserAgentClient.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(user_agent: @ua))
          @result = UserAgentClients::FindOrCreate.(@user1)
          @result_ua = @result&.user_agent_client
        end
      end

      it 'should be success' do
        expect(@result.success?).to eq(true)
      end

      it 'should create a new UserAgent for the user' do
        expect(@before_ua_count + 1).to eq(UserAgentClient.count)
        expect(@result_ua.user_id).to eq(@user1.id)
        expect(@result_ua.user_agent).to eq(@ua)
      end

      it 'should set the new UserAgent as unverified' do
        expect(@result_ua.status_id).to eq(UserAgentClientStatus.id_for(:unverified))
      end
    end

    describe '> Existing UserAgentClient' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @ua = Faker::Internet.user_agent
          @user_agent = create :user_agent_client, user_id: @user1.id, user_agent: @ua

          @before_ua_count = UserAgentClient.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(user_agent: @ua))
          @result_1 = UserAgentClients::FindOrCreate.(@user1)
          @result_1_ua = @result_1&.user_agent_client
        end
      end

      it 'should be success' do
        expect(@result_1.success?).to eq(true)
      end

      it 'should return the existing UserAgent for the user' do
        expect(@before_ua_count).to eq(UserAgentClient.count)
        expect(@result_1_ua.id).to eq(@user_agent.id)
      end

    end
  end

end
