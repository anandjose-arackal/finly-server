kyc = @result.company_kyc
json.editable @result.editable?

json.company_type kyc.company_type.name
json.completed @result.completed
json.actions @result.actions
json.documents do
  json.array!(@result.documents) do |doc|
    json.name doc[:name]
    json.options doc[:options]
  end
end

# json.system_messages do
#   json.array!(kyc&.system_messages.pluck(:content))
# end