class SamlSessionsController < BaseControllers::WebBase

  skip_before_action :verify_authenticity_token, raise: false

  def new
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def create
    sso_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)
    if sso_response.is_valid?
      # authenticate the user accordingly, and send tokens to the FE
    end
  end

  def authentication_scope
    :public
  end

  private

  # the below will be generalized based on the service provider, and (possibly) the company itself
  def saml_settings
    if Rails.env.production?
      base = "https://www.finly.io"
    else
      # base = "https://www.dev.finly.io"
      base = "http://localhost:3001"
    end

    settings = OneLogin::RubySaml::Settings.new
    settings.assertion_consumer_service_url     = "#{base}/users/saml/auth"
    settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    settings.name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
    settings.issuer                             = "#{base}/saml/metadata"
    settings.authn_context                      = ""
    # settings.idp_slo_target_url                 = "http://localhost/simplesaml/www/saml2/idp/SingleLogoutService.php"
    # settings.idp_slo_target_url                 = "https://finly-dev.onelogin.com/trust/saml2/http-redirect/slo/1049217"
    settings.idp_sso_target_url                 = "https://finly.okta.com/app/finly_finlysso_1/exk29wpyxpnjkbk6T357/sso/saml"
    # settings.idp_sso_target_url                 = "https://finly-dev.onelogin.com/trust/saml2/http-post/sso/97e57dcd-d980-410e-bab5-387691a9c379"
    settings.idp_cert_fingerprint               = "53:A4:37:75:24:33:DD:3A:9F:66:1C:86:9B:A2:BA:1E:33:F1:F0:3E"
    settings.idp_cert_fingerprint_algorithm     = "http://www.w3.org/2000/09/xmldsig#sha1"

    settings
  end
end
