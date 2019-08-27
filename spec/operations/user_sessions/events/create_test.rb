require 'rails_helper'

RSpec.describe 'UserSessions::Events::Create' do

  describe '> Browser' do
    # Setup users
    before :all do
      @company = create :company
      @user1 = create :em_user, company: @company
      @user2 = create :em_user, company: @company
      @user_device_browser = create :user_device_browser
      @doorkeeper_application1 = create :doorkeeper_application
      @token1 = create :doorkeeper_token, application: @doorkeeper_application1
      @device1 = create :user_device, client: @user_device_browser, company: @company, user: @user1

      @ip = random_ip
      @controller = 'expenses'
      @action = 'create'
      @method = 'post'
      @path = 'expenses'
    end

    describe '> Active Session' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @session1 = create :user_session, user: @user1, user_device: @device1, access_token: @token1,
                             status_id: UserSessionStatus.id_for(:authorized)
          allow(RequestStoreUtil).to receive(:current_request).and_return(double({method_symbol: @method, path: @path, ip: @ip, remote_ip: @ip}))
          allow(RequestStoreUtil).to receive(:current_app).and_return(:em)
          allow(RequestStoreUtil).to receive(:current_session).and_return(@session1)

          @before_session_events_count = UserSessionEvent.count

          @result = UserSessions::Events::Create.(@user1, {controller: @controller, action: @action})
        end
      end
      it 'should succeed' do
        expect(@result.success?).to eq(true)
      end

      it 'should a new UserSessionEvent with status as authorized' do
        expect(@before_session_events_count + 1).to eq(UserSessionEvent.count)
        expect(@result.event.status_id).to eq(UserSessionStatus.id_for(:authorized))
      end

      [:user_session_id, :http_method, :app, :path,
       :controller, :action].each do |attr|
        it "should have #{attr} set" do
          expect(@result.event.send(attr)).to_not be_nil
        end
      end
    end

    describe '> Inactive Session' do
      before :all do
        RSpec::Mocks.with_temporary_scope do
          @message = 'Revoked message'
          @session1 = create :user_session, user: @user1, user_device: @device1, access_token: @token1, status_id: UserSessionStatus.id_for(:revoked), message: @message
          allow(RequestStoreUtil).to receive(:current_request).and_return(double({method_symbol: @method, path: @path, ip: @ip, remote_ip: @ip}))
          allow(RequestStoreUtil).to receive(:current_app).and_return(:em)
          allow(RequestStoreUtil).to receive(:current_session).and_return(@session1)

          @before_session_events_count = UserSessionEvent.count

          @result = UserSessions::Events::Create.(@user1, {controller: @controller, action: @action})
        end
      end
      it 'should succeed' do
        expect(@result.success?).to eq(true)
      end

      it 'should a new UserSessionEvent with status as revoked' do
        expect(@before_session_events_count + 1).to eq(UserSessionEvent.count)
        expect(@result.event.status_id).to eq(UserSessionStatus.id_for(:revoked))
        expect(@result.event.message).to eq(@message)
      end

      [:user_session_id, :http_method, :app, :path,
       :controller, :action].each do |attr|
        it "should have #{attr} set" do
          expect(@result.event.send(attr)).to_not be_nil
        end
      end
    end
  end
end