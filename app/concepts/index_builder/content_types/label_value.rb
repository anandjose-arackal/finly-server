class IndexBuilder::ContentTypes::LabelValue < IndexBuilder::ContentTypes::Base

  register :label_value

  attribute :value
  attribute :format, default: "standard"
  attribute :label
  attribute :tool_tip, default: -> (context) { context&.dig(:data, :value)}

end