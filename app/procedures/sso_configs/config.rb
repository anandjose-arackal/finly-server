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
      'logo': "https://www.finly.io/api/common/images/playstore.png",
       'auth_url': "https://accounts.google.com/o/oauth2/auth?response_type=code&state=&client_id=307602140088-5aotklsei00379ioe94ebua3ge9nlv3s.apps.googleusercontent.com&scope=email&redirect_uri=http%3A%2F%2Flocalhost%2Fauth%2Fgoogle_oauth2%2Fcallback",
      'label': "Sign in With Google",
      'type': "oauth2"
    }
  end
end