require 'test_helper'
Dir.glob("#{Rails.root}/test/helpers/**/*.rb").each { |r| require r }

class Authentication::SuccessfulAuthTest < ActionDispatch::IntegrationTest
  include RequestHelper, RequestHelper, UserHelper

  def setup
    @ip = random_ip
    ActionDispatch::Request.any_instance.stubs(:remote_ip => @ip)
    @user = generate_user
    @email = @user.email
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
            }, headers: authentication_headers_for(:web)
          end
        end
      end
    end
    assert_response 200

    session = UserSession.last
    token = Doorkeeper::AccessToken.last
    assert_equal session.access_token_id, token.id
    assert_equal session.ip, @ip
    assert_not_nil session.user_device.user_device_browser

    body = JSON.parse(response.body)
    assert_equal body['success'], true
    assert_not_nil body['data']['access_token']
    assert_not_nil body['data']['user']['id']
    assert_nil body['data']['refresh_token']
    assert_nil body['data']['token_type']
    assert_nil body['data']['expires_in']
  end

end