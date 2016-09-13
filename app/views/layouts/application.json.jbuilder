if @result.present?
  unless @result.is_a?(BaseOperation::BasePresenter)
    json.success false
    return
  end
  if @result.success?
    data = JSON.parse yield
    # For handling mobile apis
    if @result.config.present? and @result.config[:mobile_api]
      json.success true
      json.messages @result.messages
      json.data data
    else
      unless data.present? and data.is_a?(Array)
        json.success true
        json.messages @result.messages
      end
      json.merge! data
    end
  else
    json.success false
    json.messages @result.messages
  end
else
  json.merge! JSON.parse yield
end