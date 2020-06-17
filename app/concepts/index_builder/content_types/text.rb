class IndexBuilder::ContentTypes::Text < IndexBuilder::ContentTypes::Base

  register :text

  attribute :value
  attribute :format, default: "standard"
  attribute :tool_tip, default: -> (context) { context&.dig(:data, :value) }

end