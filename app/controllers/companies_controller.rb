class CompaniesController < BaseControllers::WebBase

  def notify
    # todo
    @result = Company::ItzCashVirtualAccount::Balance.(current_user, params)
    if @result.success?
      @company_balance = @result.balance
      @company = @result.company
    else
      @company_balance = 0
      @company = nil
    end
    respond
  end

  def add_balance
    @result = Company::AddBalance.(current_user, params)
    respond
  end

  def load_options
    @result = Company::LoadOptions.(current_user, params)
    respond
  end

  def categories_and_custom_fields

  end

  def single_sign_on_configs
    subdomain = params[:subdomain] || self.request.subdomain
    company = Company.find_by(subdomain: subdomain)
    # if Rails.env.production?
    #   company = Company.find_by_sub_domain(subdomain)
    # else
    #   company = Company.first
    # end
    # company = Company.second
    @sso_configs = []
    if company.present?
      # redirect to the login page, because they don't have any configurations
      @sso_configs = company.single_sign_on_configurations
    end
    @sso_configs << {
      authentication_uri: "accounts.google.com/o/oauth2/auth?response_type=code&state=&client_id=307602140088-5aotklsei00379ioe94ebua3ge9nlv3s.apps.googleusercontent.com&scope=email&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fgoogle_oauth2%2Fcallback",
      issuer: "Finly",
      redirect_uri: "/auth/sso/google_oauth/callback",
      finly_sso_path: "/auth/sso/google_oauth/callback",
      label: "Sign in With Google",
      client_id:     Rails.application.credentials[:omniauth][:google][:client_id],
      client_secret: Rails.application.credentials[:omniauth][:google][:secret_id],
      type: "oauth2"
    }
  end

  protected

  def skip_finly_authorize?
    if [:single_sign_on_configs].include?(action_name.to_sym)
      return true
    end
    false
  end
end