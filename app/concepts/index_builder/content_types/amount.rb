class IndexBuilder::ContentTypes::Amount < IndexBuilder::ContentTypes::Base

  register :amount

  attribute :value
  attribute :currency_code
  attribute :currency_symbol
  attribute :format, default: "default"
  attribute :tool_tip, default: -> {"#{currency_code} #{value}"}

end