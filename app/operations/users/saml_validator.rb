class Users::SamlValidator < BaseOperation

  attr_accessor :sso_config_id, :sso_response, :email, :companies

  class Users::SamlValidator::SamlValidatorPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :companies, :email

    def init
      self.email = params[:email]
      self.companies = params[:companies]
    end
  end

  def init
    # fallback in case the FE doesn't send it. #TODO - handle it more gracefully
    self.sso_config_id = params[:sso_config_id]
    self.sso_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings(self.sso_config_id))
  end

  def validate
    if self.sso_config_id.blank?
      add_message :error, "Invalid SSO config passed"
      return
    end
  end

  def process
    if self.sso_response.is_valid?
      self.email = self.sso_response.name_id
      RequestStore.store[:skip_password] = true
      op = User::GroupEntitiesLogin.(nil, email_mobile: self.email)
      if op.success?
        self.companies = op.companies
      else
        add_message :error, op.messages[:error]
      end
    else
      add_message :error, "SSO login failed: #{self.sso_response.errors.to_sentence}"
    end
  end

  def success
    params[:email] = self.email
    params[:companies] = self.companies
    Users::SamlValidator::SamlValidatorPresenter.new(user, params, messages)
  end

  private

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