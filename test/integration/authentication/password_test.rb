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

  test 'Create should throw a 401 unless correct username is entered' do
    assert_no_difference 'GatekeeperBlock.count' do
      assert_no_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            unlock_user @user
            post '/oauth/token.json', params: {
                email: 'dummy@email',
                password: 'demo1234',
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

  test 'Create should throw a 401 unless correct password is entered' do
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

end