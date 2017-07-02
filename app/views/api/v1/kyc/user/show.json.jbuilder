kyc = @result.individual_kyc
json.editable kyc.editable?
json.status do
  json.id kyc.kyc_status.id
  json.name kyc.kyc_status.name.humanize
end
json.id_proof do
  json.file_type kyc.file_format(kyc.id_proof)
  json.original kyc&.id_proof&.url
  json.thumb kyc&.id_proof&.url(:thumb)
end
json.address_proof do
  json.file_type kyc.file_format(kyc.address_proof)
  json.original kyc&.address_proof&.url
  json.thumb kyc&.address_proof&.url(:thumb)
end
json.system_messages do
  json.array!(kyc&.system_messages.pluck(:content))
end