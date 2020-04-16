class IndexBuilder::ContentTypes::CheckBox < IndexBuilder::ContentTypes::Base

  register :checkbox

  attribute :value
  attribute :format, default: "standard"
  attribute :tool_tip, default: -> (context) { context[:attribute].value }

  # Send the content type as Yes/No in text format
  def content_type
    'text'
  end

  def format_value(context, user, record, exposure, data)
    if StringUtils.to_bool(data[:value].to_s)
      data[:value] = data[:tool_tip] = 'Yes'
    else
      data[:value] = data[:tool_tip] = 'No'
    end
    data
  end

end