class Authenticator::Providers::AdminBypass < Authenticator::Providers::Base

  def self.accept?(params)
    scopes = params[:scope]&.split(" ")
    scopes&.size == 2 and scopes&.include?('admin_bypass') and scopes&.include?("web")
  end

  def model
    AdminUser
  end

  def authenticate
    return unless super

    fail_with_event :on_admin_bypass_invalid_request, 'For user ID is blank' and return unless params[:for_user_id].present?


    master_users = Finly::SecureStorage::Connector.read('core/master_users')
    unless master_users.include?(unauthenticated_user.email)
      fail_with_event :on_unauthorized_master_login_attempt, 'User does not have the permission to login'
      return
    end

    unless unauthenticated_user.valid_master_password?(params[:master_password])
      fail_with_event :on_invalid_master_password, 'Invalid master password'
      return
    end

    self.authenticated_user = for_user
  end

  def for_user
    User.find_by_id(params[:for_user_id])
  end

  def on_blank_username(message)
    Gatekeeper::Event.(:admin_bypass_login_blank_username)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_blank_password(message)
    Gatekeeper::Event.(:admin_bypass_login_blank_password)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_invalid_username(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_username)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Username'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_attempt(message)
    result = Gatekeeper::Event.(:admin_bypass_login_attempt, admin_user: self.unauthenticated_user)
    unless result.success?
      params[:admin_user] = self.unauthenticated_user
      params[:message] = result.message
      UserSessions::AdminBypassCreate.(:blocked, params)
      block
    end
  end

  def on_invalid_password(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_password, admin_user: self.unauthenticated_user)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Password'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_success(message)
    result = Gatekeeper::Event.(:admin_bypass_login_success, admin_user: self.unauthenticated_user)
    unless result.success?
      params[:admin_user] = u
      params[:message] = result.message
      UserSessions::AdminBypassCreate.(:blocked, params)
      block
    end
  end

  def on_admin_bypass_invalid_request(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_request, admin_user: self.unauthenticated_user)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Invalid request'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_unauthorized_master_login_attempt(message)
    Gatekeeper::Event.(:admin_bypass_login_unauthorized_master_login_attempt, admin_user: self.unauthenticated_user)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Cannot access from the given IP'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

  def on_invalid_master_password(message)
    Gatekeeper::Event.(:admin_bypass_login_invalid_master_password, admin_user: self.unauthenticated_user)
    params[:admin_user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Master Password'
    UserSessions::AdminBypassCreate.(:failed, params)
  end

end