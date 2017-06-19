class Integrations::Quickbooks::Configuration::Show < Integrations::Quickbooks::Configuration::Base

  attr_accessor :company, :qb_config

  class Integrations::Quickbooks::Configuration::Show::ConfigurationPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :qb_config, :quickbooks_accounts

    def init
      self.qb_config = params[:qb_config]
      self.company = params[:company]
      self.quickbooks_accounts = company.quickbooks_payment_types
    end
  end


  def pre_validate
    if user.blank?
      add_message :error, "Invalid parameters"
    end
  end

end