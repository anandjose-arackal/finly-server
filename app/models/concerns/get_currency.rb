module GetCurrency
  extend ActiveSupport::Concern

  def get_reporting_currency
    Currency.find_by(id: self.reporting_currency_id) || Currency.currency_for(self.company.reporting_currency_code || "INR")
  end

  def get_base_currency
    Currency.find_by(id: self.base_currency_id) || Currency.find_by(country_code: "INR") 
  end
end