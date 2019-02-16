require 'test_helper'
# require 'helpers/authentication_helper'
Dir.glob("#{Rails.root}/test/helpers/**/*.rb").each { |r| require r }

class Authentication::AccountLockTest < ActionDispatch::IntegrationTest
  include AuthenticationHelper, IPHelper, UserHelper

  def setup
    @ip = random_ip
    ActionDispatch::Request.any_instance.stubs(:remote_ip => @ip)
    @user = generate_user
  end

  test 'More than 5 failed attempts should lock the account' do
    unlock_user @user
    assert_nil @user.reload.locked_at

    4.times.each do |i|
      assert_no_difference 'GatekeeperBlock.count' do
        assert_no_difference 'Doorkeeper::AccessToken.count' do
          assert_difference 'UserSession.count' do
            assert_difference 'UserSessionEvent.count' do
              post '/oauth/token.json', params: {
                  email: @user.email,
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
    assert_nil @user.reload.locked_at

    assert_difference 'GatekeeperBlock.count' do
      assert_no_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            post '/oauth/token.json', params: {
                email: @user.email,
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
    assert_not_nil @user.reload.locked_at
  end

  test 'Locked accounts should automatically unlock after 30 minutes' do
    time = Time.now

    assert_nil @user.reload.locked_at
    lock_user @user.reload, time
    assert_not_nil @user.reload.locked_at

    assert_difference 'GatekeeperBlock.count' do
      assert_no_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            post '/oauth/token.json', params: {
                email: @user.email,
                password: 'demo1234',
                client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                client_secret: '1976de370091732175b5661346a68bf7'
            }, headers: headers
          end
        end
      end
    end
    assert_response 401
    assert_not_nil @user.reload.locked_at

    Time.stubs(now: time + 31.minutes)
    assert_no_difference 'GatekeeperBlock.count' do
      assert_difference 'Doorkeeper::AccessToken.count' do
        assert_difference 'UserSession.count' do
          assert_difference 'UserSessionEvent.count' do
            post '/oauth/token.json', params: {
                email: @user.email,
                password: 'demo1234',
                client_id: 'ba7eafbefaf117882a2abbc9037054cf',
                client_secret: '1976de370091732175b5661346a68bf7'
            }, headers: headers
          end
        end
      end
    end
    assert_response 200

    assert_nil @user.reload.locked_at
  end

end
