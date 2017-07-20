kyc = @result.individual_kyc
json.editable kyc.editable?
json.retractable kyc.retractable?
json.kyc_number kyc&.kyc_number
json.admin_note kyc&.admin_note
json.status do
  json.id kyc.kyc_status.id
  json.name kyc.kyc_status.name.humanize
end
json.type do
  json.id kyc.type&.id
  json.name kyc.type&.name
end
json.file_1 do
  json.file_type kyc&.file_format(kyc&.kyc_file_1)
  json.original kyc&.kyc_file_1&.url
  json.thumb kyc&.kyc_file_1&.url(:thumb)
end
json.file_2 do
  json.file_type kyc&.file_format(kyc&.kyc_file_2)
  json.original kyc&.kyc_file_2&.url
  json.thumb kyc&.kyc_file_2&.url(:thumb)
end
json.profile do
  user = kyc.user
  profile = user.profile
  json.first_name user.first_name
  json.last_name user.last_name
  json.mothers_maiden_name user.mothers_maiden_name
  json.date_of_birth profile.date_of_birth&.strftime('%d-%m-%Y')
  json.gender profile.gender
  json.address_1 profile.address_1
  json.address_2 profile.address_2
  json.city profile.city
  json.state do
    json.id profile.state&.id
    json.name profile.state&.name
  end
  json.pin_code profile.pin_code
end

json.system_messages do
  json.array!(kyc&.system_messages.pluck(:content))
end