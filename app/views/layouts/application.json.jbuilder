if @result.blank? or not @result.is_a?(BaseOperation::BasePresenter)
  json.success false
  return
end
if @result.success?
  data = JSON.parse yield
  unless data.present? and data.is_a?(Array)
    json.success true
    json.messages @result.messages
  end
  json.merge! data
else
  json.success false
  json.messages @result.messages
end

# old structure
# json.success @result.success?
# if @result.blank?
#   json.success false
#   return
# end
# if @result.success?
#   data = JSON.parse(yield)
#   if data.present? and data.is_a?(Array)
#     json.array! data
#   else
#     json.success true
#     json.data data
#     json.messages @result.messages
#   end
# else
#   json.success false
#   json.messages @result.messages
# end