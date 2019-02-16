require 'test_helper'
Dir.glob("#{Rails.root}/test/helpers/**/*.rb").each { |r| require r }

class Authentication::HeaderTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper, IPHelper, UserHelper

  def setup
    @ip = random_ip
    ActionDispatch::Request.any_instance.stubs(:remote_ip => @ip)
    @user = generate_user
    @email = @user.email
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

end