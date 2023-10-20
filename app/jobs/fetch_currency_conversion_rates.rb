# fetches the conversion rates for all the currencies from the fixer.io API

class FetchCurrencyConversionRates < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name}  at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    # update the currency conversion table with details of the conversion rates
    params = {
      date: DateUtils.yesterday_local_date.strftime("%Y-%m-%d")
    }
    @result = Currency::FetchData.(nil, params)
    CurrencyConversionRate.create(@result.currency_data) rescue

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end

end
