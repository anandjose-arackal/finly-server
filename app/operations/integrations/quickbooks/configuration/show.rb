class Integrations::Quickbooks::Configuration::Show < Integrations::Quickbooks::Configuration::Base

  attr_accessor :company, :qb_config

  class Integrations::Quickbooks::Configuration::Show::ConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :qb_config, :quickbooks_accounts, :company

    def init
      self.qb_config = params[:qb_config]
      self.company = params[:company]
      self.quickbooks_accounts = company.quickbooks_payment_types
    end
  end

  def pre_validate
    if company.blank? && user.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.qb_config = company.quickbooks_configuration
  end

  def process

  end

  def success
    params[:qb_config] = qb_config
    params[:company] = company
    Integrations::Quickbooks::Configuration::Show::ConfigurationPresenter.new(user, params)
  end

end