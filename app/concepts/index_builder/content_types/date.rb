class IndexBuilder::ContentTypes::Date < IndexBuilder::ContentTypes::Base

  register :date

  attribute :value
  attribute :format, default: "standard"
  attribute :tool_tip, default: -> (context) { context[:attribute].value}

end