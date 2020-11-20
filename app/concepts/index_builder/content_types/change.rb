class IndexBuilder::ContentTypes::Change < IndexBuilder::ContentTypes::Base

  register :change

  attribute :value
  attribute :format, default: "standard"
  attribute :tool_tip, default: -> (context) { context&.dig(:data, :value)}

end