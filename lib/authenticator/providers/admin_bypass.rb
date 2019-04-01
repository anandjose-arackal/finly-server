class Authenticator::Providers::AdminBypass < Authenticator::Providers::Base

  def self.accept?(params)
    params[:scope]&.size == 2 and params[:scope]&.include?('admin_bypass') and params[:scope]&.include?("web")
  end

  def model
    AdminUser
  end

  def authenticate
    return false unless super

    fail_with_event :admin_bypass_invalid_request, 'For user ID is blank' and return false unless params[:for_user_id].present?

    master_users = Finly::SecureStorage::Connector.read('core/master_users')
    unless master_users.include?(unauthenticated_user.email)
      fail_with_event :on_unauthorized_master_login_attempt, 'User does not have the permission to login'
      return false
    end

    unless unauthenticated_user.valid_master_password?(params[:master_password])
      fail_with_event :on_invalid_master_password, 'Invalid master password'
      return false
    end

    self.authenticated_user = for_user
  end

  def for_user
    User.find_by_id(params[:for_user_id])
  end

  def on_attempt(message)
    result = Gatekeeper::Event.(:admin_bypass_login_attempt, user: u)
    unless result.success?
      params[:user] = self.unauthenticated_user
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  def on_blank_username(message)
    Gatekeeper::Event.(:admin_bypass_login_blank_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_blank_password(message)
    Gatekeeper::Event.(:admin_bypass_login_blank_password)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_username(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Username'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_password(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_password, user: u)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Password'
    UserSessions::Create.(:failed, params)
  end

  def on_success(message)
    result = Gatekeeper::Event.(:admin_bypass_login_success, user: u)
    unless result.success?
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

end