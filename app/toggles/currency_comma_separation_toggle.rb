# release/currency_comma_separation
class CurrencyCommaSeparationToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/currency_comma_separation', false
  end
end
