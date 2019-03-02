require 'rails_helper'

RSpec.describe 'UserSessions::Create' do

  describe '> Browser' do
    # Setup users
    before :all do
      @company = create :company
      @user1 = create :em_user, company: @company
      @user2 = create :em_user, company: @company
      @user_device_browser = create :user_device_browser
      @device = create :user_device, client: @user_device_browser, company: @company, user: @user1
      @ip = random_ip
      @referer = 'https://www.google.com'
      @original_url = 'https://www.finly.io/oauth/login'
    end

    describe '> Failed' do
      describe '> With user' do
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            @before_user_session_count = UserSession.count
            @before_session_event_count = UserSessionEvent.count

            headers = authentication_headers_for(:web)
            @fingerprint = JSON.parse(Base64.decode64(headers['X-Finly-RP']))['13']['7']
            @controller = 'oauth/token'
            @action = 'create'
            @path = 'oauth/login'
            @datetime = DateTime.now

            allow(RequestStoreUtil).to receive(:current_request).and_return(
                double({referer: @referer, ip: @ip, remote_ip: @ip, original_url: @original_url, headers: headers, path: @path, method_symbol: 'post'})
            )
            @message = 'Failed reason goes here'

            allow(UserDevices::FindOrCreate).to receive(:call).and_return(
                double({device: @device, success?: true})
            )

            allow(DateTime).to receive(:now).and_return(@datetime)

            @result = UserSessions::Create.(:failed, {user: @user1, username: @user1.email, scope: ['web'], controller: @controller, action: @action, message: @message})
          end
        end

        it 'should succeed' do
          expect(@result.success?).to eq(true)
        end

        it 'should create new UserSession with status as failed, message cannot be blank' do
          expect(@result.session).to_not be_nil
          expect(@before_user_session_count + 1).to eq(UserSession.count)
          expect(@result.session.status_id).to eq(UserSessionStatus.id_for(:failed))
          expect(@result.session.message).to eq(@message)
        end

        it 'should create new UserSessionEvent with the endpoint details' do
          expect(@result.event).to_not be_nil
          expect(@before_session_event_count + 1).to eq(UserSessionEvent.count)
          expect(@result.event.controller).to eq(@controller)
          expect(@result.event.action).to eq(@action)
          expect(@result.event.status_id).to eq(UserSessionStatus.id_for(:failed))
          expect(@result.event.message).to eq(@message)
          expect(@result.event.response_code).to be_nil
        end

        it 'should set the correct DateTime' do
          expect(@result.session.started_at).to eq(@datetime)
          expect(@result.session.last_request_at).to eq(@datetime)
          expect(@result.event.created_at).to_not eq(nil)
        end

        it 'should associated the respective UserDevice' do
          expect(@result.session.user_device).to eq(@device)
        end
      end
      describe '> Without user' do
        it 'should succeed' do

        end

        it 'should create new UserSession with status as failed, message cannot be blank' do

        end

        it 'should create new UserSessionEvent with the endpoint details' do

        end

        it 'should not be associated the respective UserDevice' do

        end
      end
    end

    describe '> Blocked' do
      describe '> With user' do

      end
      describe '> Without user' do

      end
    end

    describe '> Authorized' do
      describe '> With user' do

      end
      describe '> Without user' do

      end
    end
  end

end