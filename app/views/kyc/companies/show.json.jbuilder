kyc = @result.company_kyc
json.editable kyc.editable?
# json.status do
#   json.id kyc.kyc_status.id
#   json.name kyc.kyc_status.name.humanize
# end
# json.coi do
#   json.file_type kyc.file_format(kyc.coi)
#   json.original kyc&.coi&.url
#   json.thumb kyc&.coi&.url(:thumb)
# end
# json.pan_card do
#   json.file_type kyc.file_format(kyc.pan_card)
#   json.original kyc&.pan_card&.url
#   json.thumb kyc&.pan_card&.url(:thumb)
# end
json.company_type kyc.company_type.name
json.completed @result.user_completed
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