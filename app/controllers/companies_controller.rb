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
    if company.blank?
      # redirect to the login page, because they don't have any configurations
      @sso_configs = []
      return
    end
    @sso_configs = company.single_sign_on_configurations
  end

  protected

  def skip_finly_authorize?
    if [:single_sign_on_configs].include?(action_name.to_sym)
      return true
    end
    false
  end
end