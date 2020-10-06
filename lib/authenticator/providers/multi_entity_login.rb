class Authenticator::Providers::MultiEntityLogin < Authenticator::Providers::Base

  attr_accessor :company_id, :logged_in_user, :target_user

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first) and RequestStore.store[:multi_entity_login]
  end

  def model
    User
  end

  def authenticate
    self.company_id = params[:company_id]

    fail_with_event :on_blank_company_id, 'Target company not specified'
    fail_with_event :on_blank_auth_token, 'Invalid request'

    # now find the logged in user
    token = Doorkeeper::AccessToken.find_by(token: auth_token)
    self.logged_in_user = ActsAsTenant.without_tenant do
      model.find_by(id: token&.resource_owner_id)
    end

    fail_with_event :on_missing_logged_in_user, "Logged in user not found"
    self.target_user = for_user

    fail_with_event :on_missing_target_user, "No other user found"
    
    self.authenticated_user = for_user
  end

  def for_user
    email = self.logged_in_user.email
    mobile_number = self.logged_in_user.mobile_number
    ActsAsTenant.without_tenant do
      User.with_company_id(self.company_id).with_email_or_mobile_number(email, mobile_number).first
    end
  end

  def auth_token
    params[:auth_token]
  end

  def on_blank_company_id(message)
    if self.company_id.blank?
      params[:user] = self.logged_in_user
      params[:message] = message || "Company ID not passed"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_blank_auth_token(message)
    if self.auth_token.blank?
      params[:message] = message || "Auth token missing in request"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_missing_logged_in_user(message)
    if self.logged_in_user.blank?
      params[:message] = message || "Mismatched user credentials"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_missing_target_user(message)
    if self.target_user.blank?
      params[:message] = message || "Target user not found"
      UserSessions::Create.(:failed, params)
    end
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