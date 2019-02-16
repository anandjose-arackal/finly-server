require 'test_helper'
Dir.glob("#{Rails.root}/test/helpers/**/*.rb").each { |r| require r }

class Authentication::PasswordTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper, IPHelper, UserHelper

  def setup
    @ip = random_ip
    ActionDispatch::Request.any_instance.stubs(:remote_ip => @ip)
    @user = generate_user
    @email = @user.email
  end

  test 'Create should throw a 401 unless correct username and password is entered' do
    assert_no_difference 'GatekeeperBlock.count' do
      assert_no_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            unlock_user @user
            post '/oauth/token.json', params: {
                email: @email,
                password: 'demo12345',
                client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                client_secret: '1976de370091732175b5661346a68bf7'
            }, headers: headers
          end
        end
      end
    end
    assert_response 401
    body = JSON.parse(response.body)
    assert_equal body['error'], 'invalid_grant'
    assert_equal body['error_description'], 'The email / mobile or password you entered is incorrect'
  end

  test 'Create should throw a 401 unless "X-Finly-RP" is passed in the header' do
    assert_difference 'GatekeeperBlock.count' do
      assert_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            unlock_user @user
            post '/oauth/token.json', params: {
                email: @email,
                password: 'demo1234',
                client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                client_secret: '1976de370091732175b5661346a68bf7'
            }
          end
        end
      end
    end
    assert_response 401
    body = JSON.parse(response.body)
    assert_equal body['error'], 'invalid_grant'
    assert_equal body['error_description'], 'The email / mobile or password you entered is incorrect'
    assert_equal Doorkeeper::AccessToken.last.status_id, UserSessionStatus.id_for(:failed)
    assert_equal UserSession.last.status_id, UserSessionStatus.id_for(:failed)
    assert_equal UserSessionEvent.last.status_id, UserSessionStatus.id_for(:failed)
  end

  [:timestamp, :user_agent, :timezone, :fingerprint,
   :language, :browser, :browser_version,
   :browser_engine, :browser_engine_version,
   :os_name, :os_version].each do |property|
    test "Create should throw a 401 unless the request parameters #{property} is present" do
      assert_difference 'GatekeeperBlock.count' do
        assert_difference 'Doorkeeper::AccessToken.count' do
          assert_difference 'UserSession.count' do
            assert_difference 'UserSessionEvent.count' do
              unlock_user @user
              p = {}
              p[property] = nil
              post '/oauth/token.json', params: {
                  email: @email,
                  password: 'demo1234',
                  client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                  client_secret: '1976de370091732175b5661346a68bf7'
              }, headers: headers(p)
            end
          end
        end
      end
      assert_response 401
      body = JSON.parse(response.body)
      assert_equal body['error'], 'invalid_grant'
      assert_equal body['error_description'], 'The email / mobile or password you entered is incorrect'
      assert_equal Doorkeeper::AccessToken.last.status_id, UserSessionStatus.id_for(:failed)
      assert_equal UserSession.last.status_id, UserSessionStatus.id_for(:failed)
      assert_equal UserSessionEvent.last.status_id, UserSessionStatus.id_for(:failed)
    end
  end

  test 'A user cannot have more than 2 active web sessions' do
    existing_sessions = User.find_by(email: @email).user_sessions.last(2)
    existing_sessions.each do |session|
      session.update(platform: 'UserSessionWeb', status_id: UserSessionStatus.id_for(:authorized))
      session.access_token.update(status_id: UserSessionStatus.id_for(:authorized))

      assert_equal session.reload.status_id, UserSessionStatus.id_for(:authorized)
      assert_equal session.reload.status_id, UserSessionStatus.id_for(:authorized)
    end

    
    assert_difference 'Doorkeeper::AccessToken.count' do
      assert_difference 'UserSession.count' do
        post '/oauth/token.json', params: {
            email: @email,
            password: 'demo1234',
            client_id: 'ba7eafbefaf117882a2abbc9037054cf',
            client_secret: '1976de370091732175b5661346a68bf7'
        }, headers: headers
      end
    end
    assert_response 200

    assert_equal existing_sessions.first.reload.status_id, UserSessionStatus.id_for(:revoked)
    assert_equal existing_sessions.first.reload.status_id, UserSessionStatus.id_for(:revoked)
  end

  test '200 response with access token in response' do
    assert_no_difference 'GatekeeperBlock.count' do
      assert_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            unlock_user @user
            post '/oauth/token.json', params: {
                email: @email,
                password: 'demo1234',
                client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                client_secret: '1976de370091732175b5661346a68bf7'
            }, headers: headers
          end
        end
      end
    end
    assert_response 200

    session = UserSession.last
    token = Doorkeeper::AccessToken.last
    assert_equal session.access_token_id, token.id
    assert_equal session.ip, @ip
    assert_not_nil session.user_session_web

    body = JSON.parse(response.body)
    assert_equal body['success'], true
    assert_not_nil body['data']['access_token']
    assert_not_nil body['data']['user']['id']
    assert_nil body['data']['refresh_token']
    assert_nil body['data']['token_type']
    assert_nil body['data']['expires_in']
  end

end