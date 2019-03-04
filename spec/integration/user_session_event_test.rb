require 'rails_helper'
RSpec.describe 'UserSessionEvent' do

  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company

    @ip = random_ip

    @user_device_browser = create :user_device_browser
    @doorkeeper_application = create :doorkeeper_application
    @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
  end

  # describe '> Active UserSession' do
  #   describe '> Matching IP' do
  #     describe '> Valid Request' do
  #       before :all do
  #         RSpec::Mocks.with_temporary_scope do
  #           @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
  #           @session = create :user_session, access_token: @token, ip: @ip,
  #                             started_at: 15.minutes.ago, last_request_at: 10.minutes.ago
  #           @headers = {'Authorization': "Bearer #{@token.token}"}
  #
  #           @before_session_event_count = UserSessionEvent.count
  #           allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
  #           @time = Time.now
  #           allow(Time).to receive(:now).and_return(@time)
  #
  #           get '/menu_data', headers: @headers
  #         end
  #       end
  #
  #       it 'should return 200' do
  #         expect(response.status).to eq(200)
  #       end
  #
  #       it 'should create a UserSessionEvent' do
  #         expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
  #         expect(UserSessionEvent.last).to eq(@session.events.last)
  #       end
  #
  #       it 'should set the UserSessionEvents status as authorized' do
  #         expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:authorized))
  #       end
  #
  #       it 'should set UserSessions last_request_at to current time' do
  #         expect(@time - Time.parse(UserSessionEvent.last.user_session.last_request_at.to_s)).to be <= 1.minute
  #       end
  #     end
  #
  #     describe '> Timeout Request' do
  #       before :all do
  #         RSpec::Mocks.with_temporary_scope do
  #           @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
  #           @session = create :user_session, access_token: @token, ip: @ip
  #           @headers = {'Authorization': "Bearer #{@token.token}"}
  #
  #           @before_session_event_count = UserSessionEvent.count
  #           allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
  #           allow(Time).to receive(:now).and_return(Time.now + 31.minutes)
  #           get '/menu_data', headers: @headers
  #         end
  #       end
  #
  #       it 'should return 401' do
  #         expect(response.status).to eq(401)
  #       end
  #
  #       it 'should create a UserSessionEvent' do
  #         expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
  #         expect(UserSessionEvent.last).to eq(@session.events.last)
  #       end
  #
  #       it 'should set the UserSessionEvents status as revoked' do
  #         expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:revoked))
  #         expect(UserSessionEvent.last.message).to_not be_nil
  #       end
  #
  #       it 'should set the UserSession status as revoked' do
  #         expect(UserSessionEvent.last.user_session.status_id).to eq(UserSessionStatus.id_for(:revoked))
  #         expect(UserSessionEvent.last.user_session.message).to_not be_nil
  #       end
  #
  #       it 'should set the AccessToken status as revoked' do
  #         expect(UserSessionEvent.last.user_session.access_token.status_id).to eq(UserSessionStatus.id_for(:revoked))
  #         expect(UserSessionEvent.last.user_session.access_token.message).to_not be_nil
  #       end
  #     end
  #   end
  #
  #   describe '> Mismatching IP' do
  #     before :all do
  #       RSpec::Mocks.with_temporary_scope do
  #         @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
  #         @session = create :user_session, access_token: @token, ip: @ip
  #         @headers = {'Authorization': "Bearer #{@token.token}"}
  #
  #         @before_session_event_count = UserSessionEvent.count
  #         @before_gatekeeper_block_count = GatekeeperBlock.count
  #         allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(Faker::Internet.ip_v4_address)
  #         get '/menu_data', headers: @headers
  #       end
  #     end
  #
  #     it 'should return 401' do
  #       expect(response.status).to eq(401)
  #     end
  #
  #     it 'should create a GatekeeperBlock entry' do
  #       expect(@before_gatekeeper_block_count + 1).to eq(GatekeeperBlock.count)
  #     end
  #
  #     it 'should create a UserSessionEvent with status as blocked' do
  #       expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
  #       expect(UserSessionEvent.last).to eq(@session.events.last)
  #       expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #       expect(UserSessionEvent.last.message).to_not be_nil
  #     end
  #
  #     it 'should update UserSession and AccessToken as blocked' do
  #       expect(UserSessionEvent.last.user_session.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #       expect(UserSessionEvent.last.user_session.message).to_not be_nil
  #       expect(UserSessionEvent.last.user_session.access_token.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #     end
  #
  #     it 'should not allow the blocked access token to be reused from correct IP' do
  #       allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
  #       get '/menu_data', headers: @headers
  #       expect(response.status).to eq(401)
  #     end
  #   end
  # end

  describe '> Revoked UserSession' do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user1.id
        @session = create :user_session, access_token: @token, ip: @ip, status_id: UserSessionStatus.id_for(:revoked),
                          message: 'Revoke Reason'
        @headers = {'Authorization': "Bearer #{@token.token}"}

        @before_session_event_count = UserSessionEvent.count
        allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
        allow(Time).to receive(:now).and_return(Time.now)
        get '/menu_data', headers: @headers
      end
    end

    it 'should return 401' do
      expect(response.status).to eq(401)
    end

    it 'should create a UserSessionEvent' do
      expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
      expect(UserSessionEvent.last).to eq(@session.events.last)
    end

    it 'should set the UserSessionEvents status as revoked' do
      expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:revoked))
      expect(UserSessionEvent.last.message).to_not be_nil
      expect(UserSessionEvent.last.message).to eq(UserSessionEvent.last.user_session.message)
    end

  end

  # describe '> Non existent user session' do
  #   before :all do
  #     RSpec::Mocks.with_temporary_scope do
  #       @token = create :doorkeeper_token, application: @doorkeeper_application, resource_owner_id: @user2.id
  #       @headers = {'Authorization': "Bearer #{@token.token}"}
  #
  #       @before_session_event_count = UserSessionEvent.count
  #       @before_session_count = UserSession.count
  #       allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(@ip)
  #       allow(Time).to receive(:now).and_return(Time.now)
  #       get '/menu_data', headers: @headers
  #     end
  #   end
  #
  #   it 'should return 401' do
  #     expect(response.status).to eq(401)
  #   end
  #
  #   it 'should create a UserSession' do
  #     expect(@before_session_count + 1).to eq(UserSession.count)
  #   end
  #
  #   it 'should set the UserSession status as blocked' do
  #     expect(UserSession.last.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #     expect(UserSession.last.message).to_not be_nil
  #   end
  #
  #   it 'should create a UserSessionEvent' do
  #     expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
  #   end
  #
  #   it 'should set the UserSessionEvents status as blocked' do
  #     expect(UserSessionEvent.last.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #     expect(UserSessionEvent.last.message).to_not be_nil
  #   end
  #
  #   it 'should set the AccessToken status as blocked' do
  #     expect(UserSessionEvent.last.user_session.access_token.status_id).to eq(UserSessionStatus.id_for(:blocked))
  #     expect(UserSessionEvent.last.user_session.access_token.message).to_not be_nil
  #   end
  #   # With old access tokens > Create a user session
  #   # With new access token
  #   # Non existent access tokens
  # end

end