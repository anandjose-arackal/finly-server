class SingleSignOnController < Oauth::TokenController

  include ApplicationHelper
  include ActiveSupport::Concern
  include ActionController::Instrumentation

  skip_before_action :verify_authenticity_token, raise: false

  def saml
    subdomain = params[:subdomain] || self.request.subdomain
    saml_request = OneLogin::RubySaml::Authrequest.new
    company = Company.find_by(subdomain: subdomain)
    sso_config_id = params[:sso_config_id]
    sign_on_type = SingleSignOnType.id_for(action_name.to_sym)
    config = company&.single_sign_on_configurations&.with_single_sign_on_type(sign_on_type)&.with_id(sso_config_id)&.first
    ################## only for development sakes ###################
    # company = Company.second
    # config = company.single_sign_on_configurations.second
    #################################################################
    if company.present? and config.present?
      settings = saml_settings(config)
      @redirect_url = saml_request.create(settings)
    else
      @redirect_url = "/login"
    end
    render json: {redirect_url: @redirect_url}, status: 200
  end

  # this will be the catch-all controller for SAML as well as Ouath strategies
  # The logic for choosing between the strategies will be held in the Authenticator::Processor operation
  def create
    RequestStore.store[:sso] = true
    set_grant_type
    set_scope
    super()
    @token.update_columns(authentication_type: "sso")
  end

  def saml_logout
    # yet to be implemented. When though?
  end

  protected

  def on_session_create
    # SSO Sessions are always verified and do not require further OTP verification for device, IP or user agent
    # RequestStoreUtil.current_session.verify('sso')
    super()
  end

  private

  def set_grant_type
    params[:grant_type] = "password"
  end

  # the below will be generalized based on the company that is using it
  # which will be determined based on the subdomain
  # TODO - remove the placeholder configurations from below before moving to production
  def saml_settings(sso_config = SingleSignOnConfiguration.first)
    # if Rails.env.production?
    #   base = "https://www.finly.io"
    # else
    #   # base = "https://www.dev.finly.io"
    #   base = "http://localhost:3001"
    # end

    settings = OneLogin::RubySaml::Settings.new
    # settings.assertion_consumer_service_url     = "#{base}/users/saml/auth/"
    settings.assertion_consumer_service_url     = sso_config.assertion_consumer_service_url
    # settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    settings.assertion_consumer_service_binding = sso_config.assertion_consumer_service_url
    # settings.name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
    settings.name_identifier_format             = sso_config.name_identifier_format
    # settings.issuer                             = "#{base}/saml/metadata"
    settings.issuer                             = sso_config.issuer
    # settings.authn_context                      = "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
    settings.authn_context                      = sso_config.authentication_context
    # settings.idp_slo_target_url                 = "http://localhost/simplesaml/www/saml2/idp/SingleLogoutService.php"
    # settings.idp_slo_target_url                 = "https://finly-dev.onelogin.com/trust/saml2/http-redirect/slo/1049217"
    # settings.idp_sso_target_url                 = "https://finly.okta.com/app/finly_finlysso_1/exk29wpyxpnjkbk6T357/sso/saml"
    settings.idp_sso_target_url                 = sso_config.idp_sso_target_url
    # settings.idp_sso_target_url                 = "https://finly-dev.onelogin.com/trust/saml2/http-post/sso/97e57dcd-d980-410e-bab5-387691a9c379"
    # settings.idp_cert_fingerprint               = "53:A4:37:75:24:33:DD:3A:9F:66:1C:86:9B:A2:BA:1E:33:F1:F0:3E"
    # settings.idp_cert_fingerprint               = "53:38:6E:07:2A:38:B7:93:84:6D:3F:27:EF:AF:6A:21:85:F6:DC:E1"
    settings.idp_cert_fingerprint               = sso_config.idp_cert_fingerprint
    # settings.idp_cert_fingerprint_algorithm     = "http://www.w3.org/2000/09/xmldsig#sha1"
    settings.idp_cert_fingerprint_algorithm     = sso_config.idp_cert_fingerprint_algorithm

    settings
  end
end

