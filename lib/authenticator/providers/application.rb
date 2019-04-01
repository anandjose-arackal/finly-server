class Authenticator::Providers::Application < Authenticator::Providers::Base

  def self.accept?(params)
    params[:scopes]&.size == 1 and ["web", "mobile", "chrome", "api"].include?(self.scopes.first)
  end

  def model
    User
  end

  def on_attempt(message)
    result = Gatekeeper::Event.(:user_login_attempt, user: u)
    unless result.success?
      # Do not attempt login as the user account is locked
      u = nil
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  def on_blank_username(message)
    Gatekeeper::Event.(:user_login_blank_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_blank_password(message)
    Gatekeeper::Event.(:user_login_blank_password)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_username(message)
    Gatekeeper::Event.(:user_login_invalid_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Username'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_password(message)
    Gatekeeper::Event.(:user_login_invalid_password, user: u)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Password'
    UserSessions::Create.(:failed, params)
  end

  def on_success(message)
    result = Gatekeeper::Event.(:user_login_success, user: u)
    unless result.success?
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

end