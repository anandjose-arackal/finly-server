class Authenticator::Providers::MultiEntityLogin < Authenticator::Providers::Base

  attr_accessor :company_id

  def self.accept?(request)
    scopes = request.params[:scope]&.split(" ")
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first)
  end

  def authenticate
    return unless super

    logged_in_user = Doorkeeper::AccessToken.find_by(token: auth_token)


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
    self.company_id = params[:company_id]
    User.with_company_id(self.company_id).with_email_or_mobile_number(params[:for_user_id]).first
  end

  def auth_token
    params[:auth_token]
  end

  def on_blank_username(message)
    Gatekeeper::Event.(:user_login_blank_username, ip: request.remote_ip)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_blank_password(message)
    Gatekeeper::Event.(:user_login_blank_password, username: username, ip: request.remote_ip)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_username(message)
    Gatekeeper::Event.(:user_login_invalid_username, username: username, ip: request.remote_ip)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Username'
    UserSessions::Create.(:failed, params)
  end

  def on_attempt(message)
    result = Gatekeeper::Event.(:user_login_attempt, user: self.unauthenticated_user, username: username, ip: request.remote_ip)
    unless result.success?
      params[:user] = self.unauthenticated_user
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  def on_invalid_password(message)
    Gatekeeper::Event.(:user_login_invalid_password, user: self.unauthenticated_user, username: username, ip: request.remote_ip)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Password'
    UserSessions::Create.(:failed, params)
  end

  def on_success(message)
    result = Gatekeeper::Event.(:user_login_success, user: self.unauthenticated_user, username: username, ip: request.remote_ip)
    unless result.success?
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  def username
    params[:username] || params[:email] || params[:email_mobile]
  end


end