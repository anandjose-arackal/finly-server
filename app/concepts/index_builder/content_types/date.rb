class IndexBuilder::ContentTypes::Date < IndexBuilder::ContentTypes::Base

  register :date

  attribute :value
  attribute :type, default: "standard"
  attribute :tool_tip, default: -> {value}

end