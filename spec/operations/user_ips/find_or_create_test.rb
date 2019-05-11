require 'rails_helper'

RSpec.describe 'UserIps::FindOrCreate' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
    @ip = Faker::Internet.ip_v4_address
    @ip_type = 'ipv4'
  end

  describe '> Correct Params' do
    describe '> New IP' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @before_ip_count = UserIp.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(remote_ip: @ip))
          @result = UserIps::FindOrCreate.(@user1)
          @result_ip = @result&.ip
        end
      end

      it 'should be success' do
        expect(@result.success?).to eq(true)
      end

      it 'should create a new UserIP for the user' do
        expect(@before_ip_count + 1).to eq(UserIp.count)
        expect(@result_ip.user_id).to eq(@user1.id)
        expect(@result_ip.ip).to eq(@ip)
      end

      it 'should set the new UserIP as unverified' do
        expect(@result_ip.status_id).to eq(UserIpStatus.id_for(:unverified))
      end
    end

    describe '> Existing IP' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @ip = Faker::Internet.ip_v4_address
          @user_ip = create :user_ip, user_id: @user1.id, ip: @ip, ip_type: @ip_type

          @before_ip_count = UserIp.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(remote_ip: @ip))
          @result_1 = UserIps::FindOrCreate.(@user1)
          @result_1_ip = @result_1&.ip
        end
      end

      it 'should be success' do
        expect(@result_1.success?).to eq(true)
      end

      it 'should return the existing UserIP for the user' do
        expect(@before_ip_count).to eq(UserIp.count)
        expect(@result_1_ip.id).to eq(@user_ip.id)
      end

    end
  end

end
