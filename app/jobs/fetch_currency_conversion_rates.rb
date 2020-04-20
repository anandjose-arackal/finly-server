# fetches the conversion rates for all the currencies from the fixer.io API

class FetchCurrencyConversionRates

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    # update the currency conversion table with details of the conversion rates
    params = {
      date: DateUtils.yesterday_local_date.strftime("%Y-%m-%d")
    }
    @result = Currency::FetchData.(nil, params)
    CurrencyConversionRate.create(@result.currency_data)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end
