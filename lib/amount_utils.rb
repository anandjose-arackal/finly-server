class AmountUtils

  def self.format(value, options = {})
    options = {} if options.nil?
    return options[:placeholder] if value.nil?
    currency = options[:currency] || Currency.currency_for(:INR)
    symbol = currency.symbol || currency.country_code
    "#{symbol}#{value}"
  end
end