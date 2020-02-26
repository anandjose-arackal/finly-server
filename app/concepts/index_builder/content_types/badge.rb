class IndexBuilder::ContentTypes::Badge < IndexBuilder::ContentTypes::Base

  register :badge

  attribute :value
  attribute :format, default: "success"
  attribute :tool_tip, default: -> {value}

end