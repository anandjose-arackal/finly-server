class IndexBuilder::ContentTypes::Amount < IndexBuilder::ContentTypes::Base

  register :amount

  attribute :value
  attribute :currency_code
  attribute :currency_symbol
  attribute :format, default: "default"
  attribute :tool_tip, default: -> {"#{currency_code} #{value}"}

  def format_value(context, user, record, exposure, data)
    return data unless data[:value].present?
    return data unless [Amount.name, AmountExposure.name].include?(data[:value].class.name)

    amount = data[:value]
    data[:value] = amount.value
    data[:currency_code] = amount.currency&.country_code
    data[:currency_symbol] = amount.currency&.symbol
    data
  end

end