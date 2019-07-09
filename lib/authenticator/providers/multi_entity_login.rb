class Authenticator::Providers::MultiEntityLogin < Authenticator::Providers::Base

  attr_accessor :company_id, :logged_in_user, :target_user

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first) and RequestStore.store[:multi_entity_login]
  end

  def authenticate
    fail_with_event :on_blank_company_id, 'Target company not specified'
    fail_with_event :on_blank_auth_token, 'Invalid request'

    # now find the logged in user
    self.logged_in_user = Doorkeeper::AccessToken.find_by(token: auth_token)
    self.target_user = for_user

    fail_with_event :on_non_matching_user_credentials, "Target user does not have the same credentials as currently logged in user"

    self.authenticated_user = for_user
  end

  def for_user
    self.company_id = params[:company_id]
    User.with_company_id(self.company_id).with_email_or_mobile_number(params[:for_user_id]).first
  end

  def auth_token
    params[:auth_token]
  end

  def on_blank_company_id(message)
    Gatekeeper::Event.(:multi_entity_missing_blank_company, ip: request.remote_ip)
    params[:user] = self.logged_in_user
    params[:message] = message || "Company ID not passed"
    UserSessions::Create.(:failed, params)
  end

  def on_blank_auth_token(message)
    Gatekeeper::Event.(:multi_entity_missing_auth_token, ip: request.remote_ip)
    params[:user] = self.logged_in_user
    params[:message] = message || "Missing auth token"
    UserSessions::Create.(:failed, params)
  end

  def on_non_matching_user_credentials(message)
    Gatekeeper::Event.(:multi_entity_mismatch_user_credentials, ip: request.remote_ip)
    params[:user] = self.logged_in_user
    params[:message] = message || "Mismatched user credentials"
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