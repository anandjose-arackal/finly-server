class IndexBuilder::ContentTypes::Amount < IndexBuilder::ContentTypes::Base

  register :amount

  attribute :value
  attribute :currency_code
  attribute :currency_symbol
  attribute :type, default: "standard"
  attribute :tool_tip, default: -> {"#{currency_code} #{value}"}

end