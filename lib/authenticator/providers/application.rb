class Authenticator::Providers::Application < Authenticator::Providers::Base

  attr_accessor :scopes

  def self.accept?(request)
    self.scopes = request.params[:scope]
    self.scopes = [self.scopes] unless self.scopes.respond_to?(:each)
    self.scopes&.size == 1 and ["web", "mobile", "chrome", "api", "streamsets"].include?(self.scopes&.first) and !RequestStore.store[:multi_entity_login] and !RequestStore.store[:sso]
  end

  def model
    User
  end

  def company_id
    params[:company_id]
  end

  def unauthenticated_user
    raise "Model has not been defined" if model.nil?

    self.unauthenticated_user_obj ||= model.find_for_database_authentication(username: username, company_id: company_id)

    # # adding condition here to check if the company has normal logins blocked thanks to SSO
    if self.unauthenticated_user_obj&.company&.normal_login_blocked? and ["web"].include?(self.scopes.first)
      fail_with_event :on_normal_login_blocked, "Your corporate has blocked password-based logins. Please contact your administrator"
      return
    end

    self.unauthenticated_user_obj ||= model.find_for_database_authentication(username: username, company_id: company_id)
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

  # this one will check if SSO is enabled for this corporate and if
  # normal login is blocked for this corporate from another ID
  def on_normal_login_blocked(message)
    company = self.unauthenticated_user_obj&.company
    if company&.normal_login_blocked?
      params[:user] = self.unauthenticated_user_obj
      params[:message] = message || "Your corporate has blocked password-based logins. Please contact your administrator"
      UserSessions::Create.(:failed, params)
      fail
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