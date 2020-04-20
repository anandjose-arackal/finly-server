class IndexBuilder::ContentTypes::Indicator < IndexBuilder::ContentTypes::Base

  register :indicator

  attribute :value
  attribute :format, default: "success"
  attribute :tool_tip, default: -> (context) { context&.dig(:data, :value)}

end