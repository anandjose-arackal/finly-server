class FetchCurrencyConversionRates

  def perform
    # update the currency conversion table with details of the conversion rates
    params = {
      date: DateUtils.local_date.strftime("%Y-%m-%d"),
      base: "GBP"
    }
    @result = Currency::FetchData.(nil, params)
    CurrencyConversionRate.create(@result.currency_data)
  end
end