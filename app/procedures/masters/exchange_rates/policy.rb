class Masters::ExchangeRates::Policy < ApplicationPolicy
  def get_rate?
    true
  end
end
