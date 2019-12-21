# this class will handle the authentication that needs to be done for users who are logging in using SSO
class Authenticator::Providers::Sso < Authenticator::Providers::Base

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first) and RequestStore.store[:sso]
  end

  def model
    User
  end

  def on_attempt(message)
  end

  def on_blank_username(message)
  end

  def on_blank_password(message)
  end

  def on_invalid_username(message)
  end

  def on_invalid_password(message)
  end

  def on_success(message)
  end

end
