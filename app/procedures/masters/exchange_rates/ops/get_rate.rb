class Masters::ExchangeRates::Ops::GetRate < Transactions::API
  step Policy::Pundit(Masters::ExchangeRates::Policy, :get_rate?)
  step :validate
  step :get_rate!

  def validate(options, **)
    params = options[:params]
    unless Currency.find_by_country_code(params[:from]).present?
      add_message options, :error, :base, "Invalid from currency code"
      return
    end
    unless Currency.find_by_country_code(params[:to]).present?
      add_message options, :error, :base, "Invalid to currency code"
      return
    end
    unless params[:date] && Date.parse(params[:date]) <= Date.today
      add_message options, :error, :base, "Invalid date. Date should be less than today."
      return
    end
    true
  end

  def get_rate!(options, **)
    params = options[:params]
    options['exchange_rate'] = ExchangeRate.get_rate(Date.parse(params[:date]), params[:from], params[:to])
    true
  end
end
