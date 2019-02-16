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

end