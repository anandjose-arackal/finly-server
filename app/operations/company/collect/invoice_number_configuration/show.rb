class Company::Collect::InvoiceNumberConfiguration::Show < Company::Base

  attr_accessor :config

  class Company::Collect::InvoiceNumberConfiguration::Show::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :config

    def init
      self.config = params[:config]
    end
  end

  def init
    self.config = user.company.invoice_number_config
  end

  def success
    params[:config] = self.config
    Company::Collect::InvoiceNumberConfiguration::Show::ConfigPresenter.new(user, params, messages)
  end
end