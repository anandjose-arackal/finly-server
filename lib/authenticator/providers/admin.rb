class Authenticator::Providers::Admin < Authenticator::Providers::Base

  def self.accept?(params)
    scopes = params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and scopes&.include?('admin')
  end

  def model
    AdminUser
  end

  def on_attempt(message)
    result = Gatekeeper::Event.(:admin_user_login_attempt, user: u)
    unless result.success?
      params[:user] = self.unauthenticated_user
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  def on_blank_username(message)
    Gatekeeper::Event.(:admin_user_login_blank_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_blank_password(message)
    Gatekeeper::Event.(:admin_user_login_blank_password)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Blank Password'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_username(message)
    Gatekeeper::Event.(:admin_user_login_invalid_username)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Username'
    UserSessions::Create.(:failed, params)
  end

  def on_invalid_password(message)
    Gatekeeper::Event.(:admin_user_login_invalid_password, user: u)
    params[:user] = self.unauthenticated_user
    params[:message] = message || 'Invalid Password'
    UserSessions::Create.(:failed, params)
  end

  def on_success(message)
    result = Gatekeeper::Event.(:admin_user_login_success, user: u)
    unless result.success?
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

end