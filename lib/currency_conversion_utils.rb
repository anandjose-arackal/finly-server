class CurrencyConversionUtils

  def self.converted_amount(date = nil, amount = nil)
    return 0 if date.blank? || amount.nil?
    return 0 unless amount.is_a?(Numeric)
    date = Date.parse(date) unless date.is_a?(Date)
    rate = CurrencyConversionRate.find_by(date: date)
    if rate.nil?
      
    end
    converted_amount = CurrencyConversionRate.find_by(date: date) * amount
  end
end