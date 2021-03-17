class FormCurrency < ApplicationRecord

  def currency_conversion_rate
    ExchangeRate.get_rate(
        Date.yesterday,
        RequestStoreUtil.current_user.company.reporting_currency_code,
        self.currency_code
    ).to_f rescue 1
  end
end