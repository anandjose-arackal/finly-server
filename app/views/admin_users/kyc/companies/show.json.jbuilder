# json.kyc do
#   kyc = @result.company_kyc
#   editable = (kyc.editable? or [KycStatus.id_for(:processing)].include?(kyc.kyc_status_id))
#   json.editable editable
#   json.status do
#     json.id kyc.kyc_status.id
#     json.name kyc.kyc_status.name.humanize
#   end
#   json.coi do
#     json.file_type kyc.file_format(kyc.coi)
#     json.original kyc&.coi&.url
#     json.thumb kyc&.coi&.url(:thumb)
#   end
#   json.pan_card do
#     json.file_type kyc.file_format(kyc.pan_card)
#     json.original kyc&.pan_card&.url
#     json.thumb kyc&.pan_card&.url(:thumb)
#   end
#   json.system_messages do
#     json.array!(kyc&.system_messages.pluck(:content))
#   end
# end
kyc = @result.company_kyc
json.editable true # because admin panel is always editable
json.company_type kyc.company_type.name
json.completed @result.completed
json.actions @result.actions
json.documents do
  json.array!(@result.documents) do |doc|
    json.name doc[:name]
    json.options doc[:options]
  end
end