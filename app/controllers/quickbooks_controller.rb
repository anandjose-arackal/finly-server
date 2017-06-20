class QuickbooksController < ApplicationController

  allow_oauth!

  def sync_report
    @result = Integrations::Quickbooks::SyncReport.(current_company, params, current_user)
    respond
  end

  def sync_reports
    @result = Integrations::Quickbooks::SyncReports.(current_company, params, current_user)
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

end