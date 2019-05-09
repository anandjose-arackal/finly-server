class TaxRates::Index < TaxRates::Base

  class TaxRates::Index::TaxRatesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :tax_rates

    def init
      self.tax_rates = params[:tax_rates]
    end
  end

  def init
    self.company = user.company
  end

  def process
    self.tax_rates = self.company.tax_rates
  end

  def success
    params[:tax_rates] = self.tax_rates
    TaxRates::Index::TaxRatesPresenter.new(user, params, messages)
  end
end