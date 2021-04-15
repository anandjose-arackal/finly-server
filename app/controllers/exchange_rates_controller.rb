class ExchangeRatesController < BaseControllers::WebBase
  layout 'trailblazers'

  def get_rate
    endpoint Masters::ExchangeRates::Ops::GetRate
  end

end
