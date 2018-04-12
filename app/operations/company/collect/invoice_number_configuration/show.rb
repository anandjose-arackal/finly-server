class Company::Collect::InvoiceNumberConfiguration::Show < Company::Base

  attr_accessor :configs

  class Company::Collect::InvoiceNumberConfiguration::Show::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :configs

    def init
      self.configs = params[:configs]
    end
  end

  def init
    self.configs = user.company.invoice_number_configs.with_purpose_id(Purpose.id_for(:collect))
  end

  def success
    params[:configs] = self.configs
    Company::Collect::InvoiceNumberConfiguration::Show::ConfigPresenter.new(user, params, messages)
  end
end