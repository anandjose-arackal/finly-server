class Authenticator::Providers::Application < Authenticator::Providers::Base

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first)
  end

  def model
    User
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