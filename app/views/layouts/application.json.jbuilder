if @result.present?
  unless @result.class.method_defined?(:success?) and @result.class.method_defined?(:failure?)
    json.success false
    return
  end
  if @result.success?
    data = JSON.parse yield rescue nil
    # For handling mobile apis
    if @result.config.present? and @result.config[:mobile_api]
      json.success true
      if @result.messages.present?
        unless @result.messages[:error].blank?
          @result[:messages]
        end
      end
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
  json.merge! JSON.parse yield rescue nil
end