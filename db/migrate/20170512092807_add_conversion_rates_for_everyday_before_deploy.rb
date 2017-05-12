class AddConversionRatesForEverydayBeforeDeploy < ActiveRecord::Migration
  def change
    date = DateUtils.yesterday_local_date
    while date >= Date.parse('01-04-2017')
      params = {
          date: date.strftime("%Y-%m-%d"),
          base: "GBP"
      }
      @result = Currency::FetchData.(nil, params)
      CurrencyConversionRate.create(@result.currency_data)
      date -= 1 # i.e. reducing the date by one
    end
  end
end
