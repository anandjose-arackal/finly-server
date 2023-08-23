class Authenticator::SsoConfig < Transactions::API
  skip_user_authorization!

  step :find_company
  step :get_saml
  step :get_google_oauth
  step :set_results

  def find_company(options, params:, **)
    subdomain = params[:subdomain] || options[:request]&.subdomain
    company = Company.find_by(subdomain: subdomain)
    # company = Company.find_by(id: 2)
    options[:company] = company
    true
  end

  def get_saml(options, params:, **)
    options[:sso_configs] = []
    if options[:company].present?
      sso_configs = options[:company].single_sign_on_configurations
      options[:sso_configs] << sso_configs
    end
    true
  end

  def get_google_oauth(options, params:, **)
    company = options[:company]
    if company.present?
      user = company.users.first
      toggle = AuthenticationToggle.new( user )
      options[:sso_configs] << google_sso_config if toggle.sso_google_enabled?
    else
      options[:sso_configs] << google_sso_config
    end

    true
  end

  def set_results(options, params:, **)
    options['result'] = options[:sso_configs].compact.flatten
    true
  end

  def google_sso_config
    # redirect_uri = "#{Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:base_url]}/auth/google_oauth2/callback"
    # client_id = Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:client_id]
    # sso_configs = {
    #   'issuer': "Finly",
    #   'logo': "https://img.icons8.com/color/24/000000/google-logo.png",
    #   'auth_url': "https://accounts.google.com/o/oauth2/auth?response_type=code&state=&client_id=#{client_id}&scope=email&redirect_uri=#{redirect_uri}",
    #   'label': "Google",
    #   "provider": "google_oauth2",
    #   'sso_type': "oauth2"
    # }
    # sso_configs
    true
  end
end