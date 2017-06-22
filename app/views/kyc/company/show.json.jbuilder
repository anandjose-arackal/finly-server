kyc = @result.company_kyc
json.status do
  json.id kyc.kyc_status.id
  json.name kyc.kyc_status.name.humanize
end
json.coi do
  json.file_type kyc.file_format(kyc.coi)
  json.original kyc&.coi&.url
  json.thumb kyc&.coi&.url(:thumb)
  json.system_messages do
    json.array!(kyc&.coi&.system_messages.pluck(:content))
  end
end
json.pan_card do
  json.file_type kyc.file_format(kyc.pan_card)
  json.original kyc&.pan_card&.url
  json.thumb kyc&.pan_card&.url(:thumb)
  json.system_messages do
    json.array!(kyc&.pan_card&.system_messages.pluck(:content))
  end
end