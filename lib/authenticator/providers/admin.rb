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