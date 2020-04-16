class IndexBuilder::ContentTypes::Amount < IndexBuilder::ContentTypes::Base

  register :amount

  attribute :value
  attribute :currency_code
  attribute :currency_symbol
  attribute :format, default: "default"
  attribute :tool_tip, default: -> (context) { "#{context[:attribute].currency_code} #{context[:attribute].value}"}

  def format_value(context, user, record, exposure, data)
    # return data unless data[:value].present?
    unless [Amount.name, AmountExposure.name].include?(data[:value].class.name)
      data[:value] = 0 if data[:value].blank?
      data[:currency_code] = 'INR' if data[:currency_code].blank?
      data[:currency_symbol] = '₹' if data[:currency_symbol].blank?
      return data
    end

    amount = data[:value]
    data[:value] = amount.value
    data[:currency_code] = amount.currency&.country_code
    data[:currency_symbol] = amount.currency&.symbol
    data
  end

end