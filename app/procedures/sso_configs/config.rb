class SsoConfigs::Config < Transactions::API
  skip_user_authorization!

  step :find_company
  step :get_saml
  step :get_google_oauth
  step :set_results

  def find_company(options, params:, **)
    subdomain = params[:subdomain] || self.request.subdomain
    company = Company.find_by(subdomain: subdomain)
    options[:company] = company
    true
  end

  def get_saml(options, params:, **)
    options[:sso_configs] = []
    if options[:company].present?
      sso_configs = company.single_sign_on_configurations
    end
    options[:sso_configs] << sso_configs
    true
  end

  def get_google_oauth(options, params:, **)
    company = options[:company]
    if company.present?
      user = company.users.first
      toggel = AuthenticationToggle.new( user )
    
      options[:sso_configs] << google_sso_config if toggel.sso_google_enabled?

    else
      options[:sso_configs] << google_sso_config
    end

    true
  end

  def set_results(options, params:, **)
    options['result'] = options[:sso_configs].compact
    true
  end

  def google_sso_config
    sso_configs = {
      'issuer': "Finly",
      'redirect_uri': "/auth/sso/google_oauth/callback",
      'label': "Sign in With Google",
      'client_id': Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:client_id],
      'type': "oauth2"
    }
  end
end