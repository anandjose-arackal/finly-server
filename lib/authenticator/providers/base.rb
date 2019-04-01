class Authenticator::Providers::Base
  attr_accessor :params, :unauthenticated_user_obj, :authenticated_user, :failed, :blocked, :message

  def self.accept?(params)
    false
  end

  def initialize(params)
    self.params = params
  end

  def authenticate
    on_event :on_attempt
    return false if failed? or blocked?

    fail_with_event :on_blank_username, 'Blank username' and return false if username.blank?
    fail_with_event :on_blank_password, 'Blank password' and return false if password.blank?
    fail_with_event :on_invalid_username, 'User not found' and return false if unauthenticated_user.blank?
    fail_with_event :on_invalid_password, 'Invalid password' and return false if unauthenticated_user.valid_password?(password)

    on_event :on_success
    return false if failed? or blocked?

    self.authenticated_user = self.unauthenticated_user
  end

  def model
    nil
  end

  def username
    params[:username]
  end

  def password
    params[:password]
  end

  def unauthenticated_user
    raise "Model has not been defined" if model.nil?

    self.unauthenticated_user_obj ||= model.find_for_database_authentication(username: username)
  end

  def on_event(name, message = nil)
    self.send(name, message) if self.respond_to?(name)
  end

  def fail_with_event(event, message)
    fail
    on_event event, message
  end

  def block_with_event(event, message)
    block
    on_event event, message
  end

  def fail
    self.failed = true
  end

  def block
    self.blocked = true
  end

  def failed?
    !!self.failed
  end

  def blocked?
    !!self.blocked
  end

  def success?
    self.authenticated_user.present?
  end

  def on_attempt(message = nil)

  end

  def on_blank_username(message = nil)

  end

  def on_blank_password(message = nil)

  end

  def on_invalid_username(message = nil)

  end

  def on_invalid_password(message = nil)

  end

  def on_success(message = nil)

  end

end