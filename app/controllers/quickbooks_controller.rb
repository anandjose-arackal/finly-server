class QuickbooksController < BaseControllers::WebBase

  before_action :add_company_to_params

  def sync_report
    @result = Integrations::Quickbooks::InitiateReportsSync.(current_user, params)
    respond
  end

  def sync_reports
    @result = Integrations::Quickbooks::InitiateReportsSync.(current_user, params)
    respond
  end

  def sync_categories
    @result = Integrations::Quickbooks::SyncCategories.(current_company, params, current_user)
    respond
  end

  def sync_payment_types
    @result = Integrations::Quickbooks::SyncPaymentTypes.(current_company, params, current_user)
    respond
  end

  def sync_users
    @result = Integrations::Quickbooks::SyncUsers.(current_company, params, current_user)
    respond
  end

  # action that updates the configuration for the quickbooks sync
  def update
    @result = Integrations::Quickbooks::Configuration::Update.(current_company, params, current_user)
    respond
  end

  def show
    @result = Integrations::Quickbooks::Configuration::Show.(current_company, params, current_user)
    respond
  end

  private

  def current_company
    current_user.company
  end

  def add_company_to_params
    params[:company_id] = current_user.company_id
  end

end
