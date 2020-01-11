# this class will handle the authentication that needs to be done for users who are logging in using SSO
# For now this only supports SAML based authentication, but it can support others in the future
class Authenticator::Providers::Sso < Authenticator::Providers::Base

  attr_accessor :username, :sso_response, :sso_config_id, :company_id

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first) and RequestStore.store[:sso]
  end

  def model
    User
  end

  def authenticate
    self.sso_config_id = params[:sso_config_id]
    self.company_id = params[:company_id]

    # i.e. setting the sso_config as the first one as a fallback
    self.sso_config_id = 1 if self.sso_config_id.blank?

    fail_with_event :on_invalid_sso_config, "Invalid configuration passed for SSO"

    self.sso_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings(self.sso_config_id))

    fail_with_event :on_invalid_saml_session, "Invalid login details given. Please contact your system administrator"
    fail_with_event :on_blank_username, "Invalid username"

    self.authenticated_user = unauthenticated_user
  end

  # this is the user that will be created once the
  # company is passed
  def unauthenticated_user
    raise "Model has not been defined" if model.nil?

    self.unauthenticated_user_obj ||= model.find_for_database_authentication(username: username, company_id: self.company_id)
  end

  def on_invalid_saml_session(message)
    unless self.sso_response.is_valid?
      params[:message] = self.sso_response.errors || "Invalid login details"
      UserSessions::Create.(:failed, params)
    end
  end

  def username
    self.sso_response.name_id
  end

  def on_invalid_sso_config(message)
    sso_config = SingleSignOnConfiguration.find_by(id: self.sso_config_id)
    if sso_config.blank?
      params[:message] = message || "Invalid configuration passed for SSO"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_blank_username(message)
    if username.blank?
      params[:message] = message || "Invalid username"
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

  def saml_settings(config_id)
    sso_config = SingleSignOnConfiguration.find_by(id: config_id)
    if sso_config.blank?
      # return error message
      params[:message] = "Invalid configuration passed for SSO"
      UserSessions::Create.(:failed, params)
    end
    settings = OneLogin::RubySaml::Settings.new
    settings.assertion_consumer_service_url     = sso_config.assertion_consumer_service_url
    settings.assertion_consumer_service_binding = sso_config.assertion_consumer_service_url
    settings.name_identifier_format             = sso_config.name_identifier_format
    settings.issuer                             = sso_config.issuer
    settings.authn_context                      = sso_config.authentication_context
    settings.idp_sso_target_url                 = sso_config.idp_sso_target_url
    settings.idp_cert_fingerprint               = sso_config.idp_cert_fingerprint
    settings.idp_cert_fingerprint_algorithm     = sso_config.idp_cert_fingerprint_algorithm

    settings
  end

end
