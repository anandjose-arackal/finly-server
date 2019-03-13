require 'rails_helper'

class UserSessionCreateHelper
  def self.init_with_user(instance)
    instance.before(:all) do
      RSpec::Mocks.with_temporary_scope do
        @before_user_session_count = UserSession.count
        @before_session_event_count = UserSessionEvent.count

        headers = authentication_headers_for(:web)
        @fingerprint = JSON.parse(Base64.decode64(headers['X-Finly-RP']))['13']['7']
        @controller = 'oauth/token'
        @action = 'create'
        @path = 'oauth/login'

        @username = @user1.email

        allow(RequestStoreUtil).to receive(:current_request).and_return(double({referer: @referer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post'}))
        allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({device: @device, success?: true}))
        allow(UserIps::FindOrCreate).to receive(:call).and_return(double({ip: @ip_addr, success?: true}))

        response = double({token: @token})
        @result = UserSessions::Create.(@status, {user: @user1, response: response, username: @username, scope: ['web'], controller: @controller, action: @action, message: @message})
      end
    end
  end

  def self.init_without_user(instance)
    instance.before(:all) do
      RSpec::Mocks.with_temporary_scope do
        @before_user_session_count = UserSession.count
        @before_session_event_count = UserSessionEvent.count

        headers = authentication_headers_for(:web)
        @fingerprint = JSON.parse(Base64.decode64(headers['X-Finly-RP']))['13']['7']
        @controller = 'oauth/token'
        @action = 'create'
        @path = 'oauth/login'

        @username = @user1.email

        allow(RequestStoreUtil).to receive(:current_request).and_return(double({referer: @referer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post'}))
        @message = 'Failed reason goes here'
        allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({device: @device, success?: true}))
        allow(UserIps::FindOrCreate).to receive(:call).and_return(double({ip: @ip_addr, success?: true}))

        response = double({token: @token})
        block.call if block_given?
        @result = UserSessions::Create.(@status, {user: nil, response: response, username: @username, scope: ['web'], controller: @controller, action: @action, message: @message})
      end
    end
  end

  def self.user_session_property_check(instance)
    instance.it 'should succeed' do
      expect(@result.success?).to eq(true)
    end

    instance.it "should create new UserSession with status as #{@status}, message cannot be blank" do
      expect(@result.session).to_not be_nil
      expect(@before_user_session_count + 1).to eq(UserSession.count)
      expect(@result.session.status_id).to eq(UserSessionStatus.id_for(@status))
      expect(@result.session.message).to eq(@message)
    end

    instance.it 'should create new UserSessionEvent with the endpoint details' do
      expect(@result.event).to_not be_nil
      expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
      expect(@result.event.controller).to eq(@controller)
      expect(@result.event.action).to eq(@action)
      expect(@result.event.status_id).to eq(UserSessionStatus.id_for(@status))
      expect(@result.event.message).to eq(@message)
      expect(@result.event.response_code).to be_nil
    end

    instance.it 'should set the correct DateTime' do
      expect(@result.session.started_at).to_not be_nil
      expect(@result.session.last_request_at).to_not be_nil
      expect(@result.event.created_at).to_not be_nil
    end

    [
        :continent_name, :continent_code, :country_name,
        :country_code, :region_code, :region_name,
        :city, :zip, :latitude, :longitude, :accuracy_radius,
        :referrer, :ip, :ip_type, :landing_page
    ].each do |item|
      instance.it "should have set #{item}" do
        expect(@result.session.send(item)).to_not be_nil
      end
    end
  end

  def self.user_presence_check(instance)
    instance.it 'should have user and company set' do
      expect(@result.session.user).to eq(@user1)
      expect(@result.session.company).to eq(@company)
      expect(@result.session.username).to eq(@username)
    end

    instance.it 'should set the UserSession IP to request IP' do
      expect(@result.session.user_ip_id).to eq(@ip_addr.id)
    end

    instance.it 'should have UserDevice be set' do
      expect(@result.session.user_device_id).to eq(@device.id)
    end
  end

  def self.user_absence_check(instance)
    instance.it 'should have user and company blank' do
      expect(@result.session.user).to be_nil
      expect(@result.session.company).to be_nil
      expect(@result.session.username).to eq(@username)
    end

    instance.it 'should have UserSession IP nil' do
      expect(@result.session.user_ip_id).to be_nil
    end

    instance.it 'should have UserDevice as nil' do
      expect(@result.session.user_device_id).to be_nil
    end
  end
end

RSpec.describe 'UserSessions::Create' do

  describe '> Browser' do
    # Setup users
    before :all do
      @company = create :company
      @user1 = create :em_user, company: @company
      @user2 = create :em_user, company: @company
      @user_device_browser = create :user_device_browser
      @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
      @ip = '106.51.25.1'
      @ip_addr = create :user_ip, ip: @ip, user_id: @user1.id
      @referer = 'https://www.google.com'
      @original_url = 'https://www.finly.io/oauth/login'
    end

    describe '> Failed' do
      before(:all) do
        @status = :failed
        @message = 'Failed reason goes here'
      end

      describe '> With user' do
        UserSessionCreateHelper.init_with_user(self)
        UserSessionCreateHelper.user_session_property_check(self)
        UserSessionCreateHelper.user_presence_check(self)
      end

      describe '> Without user' do
        UserSessionCreateHelper.init_without_user(self)
        UserSessionCreateHelper.user_session_property_check(self)
        UserSessionCreateHelper.user_absence_check(self)
      end

    end

    describe '> Blocked' do
      before(:all) do
        @status = :blocked
        @message = 'Blocked reason goes here'
      end

      describe '> With user' do
        UserSessionCreateHelper.init_with_user(self)
        UserSessionCreateHelper.user_session_property_check(self)
        UserSessionCreateHelper.user_presence_check(self)
      end

      describe '> Without user' do
        UserSessionCreateHelper.init_without_user(self)
        UserSessionCreateHelper.user_session_property_check(self)
        UserSessionCreateHelper.user_absence_check(self)
      end
    end

    describe '> Authorized' do
      before(:all) do
        @status = :authorized
        @doorkeeper_application = create :doorkeeper_application
        @token = create(:doorkeeper_token, application_id: @doorkeeper_application.id)
      end

      describe '> With user' do
        UserSessionCreateHelper.init_with_user(self)
        UserSessionCreateHelper.user_session_property_check(self)
        UserSessionCreateHelper.user_presence_check(self)
      end

      describe '> With user with FailurePresenter from UserDevices::FindOrCreate' do
        before do
          RSpec::Mocks.with_temporary_scope do
            @before_user_session_count = UserSession.count
            @before_session_event_count = UserSessionEvent.count

            headers = {}
            @controller = 'oauth/token'
            @action = 'create'
            @path = 'oauth/login'

            @username = @user1.email
            @issue_string = 'Issue issue'

            allow(RequestStoreUtil).to receive(:current_request).and_return(double({referer: @referer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post'}))
            allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({success?: false, messages: {error: [@issue_string]}}))
            allow(UserIps::FindOrCreate).to receive(:call).and_return(double({ip: @ip_addr, success?: true}))

            response = double({token: @token})
            @result = UserSessions::Create.(@status, {user: @user1, response: response, username: @username, scope: ['web'], controller: @controller, action: @action, message: @message})
          end
        end

        it 'should succeed' do
          expect(@result.success?).to eq(true)
        end

        it 'should set UserSession as failed' do
          expect(@result.session.status_id).to eq(UserSessionStatus.id_for(:failed))
          expect(@result.session.message).to eq(@issue_string)
        end
      end

      describe '> With user with FailurePresenter from UserIps::FindOrCreate' do
        before do
          RSpec::Mocks.with_temporary_scope do
            @before_user_session_count = UserSession.count
            @before_session_event_count = UserSessionEvent.count

            headers = {}
            @controller = 'oauth/token'
            @action = 'create'
            @path = 'oauth/login'

            @username = @user1.email
            @issue_string = 'Issue issue'

            allow(RequestStoreUtil).to receive(:current_request).and_return(double({referer: @referer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post'}))
            allow(UserDevices::FindOrCreate).to receive(:call).and_return(double({device: @device, success?: true}))
            allow(UserIps::FindOrCreate).to receive(:call).and_return(double({success?: false, messages: {error: [@issue_string]}}))

            response = double({token: @token})
            @result = UserSessions::Create.(@status, {user: @user1, response: response, username: @username, scope: ['web'], controller: @controller, action: @action, message: @message})
          end
        end

        it 'should succeed' do
          expect(@result.success?).to eq(true)
        end

        it 'should set UserSession as failed' do
          expect(@result.session.status_id).to eq(UserSessionStatus.id_for(:failed))
          expect(@result.session.message).to eq(@issue_string)
        end
      end

      describe '> Without user' do
        UserSessionCreateHelper.init_without_user(self)

        it 'should not succeed' do
          expect(@result.success?).to eq(false)
        end

        it 'should not create UserSession' do
          expect(@before_user_session_count).to eq(UserSession.count)
        end

        it 'should not create UserSessionEvent' do
          expect(@before_session_event_count).to eq(UserSessionEvent.count)
        end
      end
    end
  end

end