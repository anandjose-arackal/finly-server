class QuickbooksController < ApplicationController

  before_action :add_company_to_params
  before_action -> { doorkeeper_authorize! :web}

  def sync_report
    @result = Integrations::Quickbooks::SyncReport.call_async(current_user.id, params)
    respond response: :success, message: "Report Sync initiated"
  end

  def sync_reports
    @result = Integrations::Quickbooks::SyncReports.call_async(current_user.id, params)
    respond response: :success, message: "Reports Sync initiated"
  end

  def sync_categories
    @result = Integrations::Quickbooks::SyncCategories.(current_company, params, current_user)
    respond
  end

  def sync_payment_types
    @result = Integrations::Quickbooks::SyncPaymentTypes.(current_company, params, current_user)
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