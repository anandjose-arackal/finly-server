class IndexBuilder::ContentTypes::Change < IndexBuilder::ContentTypes::Base

  register :change

  attribute :value
  attribute :format, default: "standard"
  attribute :label
  attribute :tool_tip, default: -> (context) do
    if context&.dig(:data, :value).present?
      values = context&.dig(:data, :value)
      "#{context&.dig(:data, :label)} changed from #{(values.first.nil? ? "Blank" : values.first)} to #{(values.last.nil? ? "Blank" : values.last)}"
    end
  end

end