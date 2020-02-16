kyc = @result.individual_kyc
json.require_photo kyc.require_photo?
json.editable kyc.editable?
json.retractable kyc.retractable?
json.initiated kyc.initiated
json.card_serial kyc.user&.cards&.first&.proxy
json.kyc_operation_phone_number (kyc.initiated? ? '' : @result.kyc_operation_phone_number)
json.kyc_number kyc&.kyc_number
json.kyc_1_number kyc&.kyc_1_number
json.kyc_2_number kyc&.kyc_2_number
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
  json.file_format kyc&.file_format(kyc&.kyc_file_1)
  json.original (Rails.env.production? ? kyc&.kyc_file_1&.url : "/api/#{kyc&.kyc_file_1&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_file_1&.url(:thumb) : "/api/#{kyc&.kyc_file_1&.url(:thumb)}")
end
json.file_2 do
  json.file_type kyc&.file_format(kyc&.kyc_file_2)
  json.file_format kyc&.file_format(kyc&.kyc_file_2)
  json.original (Rails.env.production? ? kyc&.kyc_file_2&.url : "/api/#{kyc&.kyc_file_2&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_file_2&.url(:thumb) : "/api/#{kyc&.kyc_file_2&.url(:thumb)}")
end
json.aadhar_front do
  json.file_format kyc&.file_format(kyc&.aadhar_front)
  json.file_type kyc.file_format(kyc.aadhar_front)
  json.original kyc&.aadhar_front&.url
  json.thumb kyc&.aadhar_front&.url(:thumb)
end
json.aadhar_back do
  json.file_format kyc&.file_format(kyc&.aadhar_back)
  json.file_type kyc.file_format(kyc.aadhar_back)
  json.original kyc&.aadhar_back&.url
  json.thumb kyc&.aadhar_back&.url(:thumb)
end
json.signature do
  json.file_format kyc&.file_format(kyc&.signature)
  json.file_type kyc.file_format(kyc.signature)
  json.original (Rails.env.production? ? kyc&.signature&.url : "/api/#{kyc&.signature&.url}")
  json.thumb (Rails.env.production? ? kyc&.signature&.url(:thumb) : "/api/#{kyc&.signature&.url(:thumb)}")
end
json.kyc_1_front do
  json.file_format kyc&.file_format(kyc&.kyc_1_front)
  json.file_type kyc.file_format(kyc.kyc_1_front)
  json.original (Rails.env.production? ? kyc&.kyc_1_front&.url : "/api/#{kyc&.kyc_1_front&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_1_front&.url(:thumb) : "/api/#{kyc&.kyc_1_front&.url(:thumb)}")
end
json.kyc_1_front do
  json.file_format kyc&.file_format(kyc&.kyc_1_front)
  json.file_type kyc.file_format(kyc.kyc_1_front)
  json.original (Rails.env.production? ? kyc&.kyc_1_front&.url : "/api/#{kyc&.kyc_1_front&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_1_front&.url(:thumb) : "/api/#{kyc&.kyc_1_front&.url(:thumb)}")
end

json.kyc_1_back do
  json.file_format kyc&.file_format(kyc&.kyc_1_back)
  json.file_type kyc.file_format(kyc.kyc_1_back)
  json.original (Rails.env.production? ? kyc&.kyc_1_back&.url : "/api/#{kyc&.kyc_1_back&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_1_back&.url(:thumb) : "/api/#{kyc&.kyc_1_back&.url(:thumb)}")
end
json.kyc_2_front do
  json.file_format kyc&.file_format(kyc&.kyc_2_front)
  json.file_type kyc.file_format(kyc.kyc_2_front)
  json.original (Rails.env.production? ? kyc&.kyc_2_front&.url : "/api/#{kyc&.kyc_2_front&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_2_front&.url(:thumb) : "/api/#{kyc&.kyc_2_front&.url(:thumb)}")
end
json.kyc_2_back do
  json.file_format kyc&.file_format(kyc&.kyc_2_back)
  json.file_type kyc.file_format(kyc.kyc_2_back)
  json.original (Rails.env.production? ? kyc&.kyc_2_back&.url : "/api/#{kyc&.kyc_2_back&.url}")
  json.thumb (Rails.env.production? ? kyc&.kyc_2_back&.url(:thumb) : "/api/#{kyc&.kyc_2_back&.url(:thumb)}")
end
json.photo do
  json.file_format kyc&.file_format(kyc&.photo)
  json.file_type kyc.file_format(kyc.photo)
  json.original (Rails.env.production? ? kyc&.photo&.url : "/api/#{kyc&.photo&.url}")
  json.thumb (Rails.env.production? ? kyc&.photo&.url(:thumb) : "/api/#{kyc&.photo&.url(:thumb)}")
end
json.id_proof_front do
  json.file_format kyc&.file_format(kyc&.id_proof_front)
  json.file_type kyc.file_format(kyc.id_proof_front)
  json.original (Rails.env.production? ? kyc&.id_proof_front&.url : "/api/#{kyc&.id_proof_front&.url}")
  json.thumb (Rails.env.production? ? kyc&.id_proof_front&.url(:thumb) : "/api/#{kyc&.id_proof_front&.url(:thumb)}")
end
json.id_proof_back do
  json.file_format kyc&.file_format(kyc&.id_proof_back)
  json.file_type kyc.file_format(kyc.id_proof_back)
  json.original (Rails.env.production? ? kyc&.id_proof_back&.url : "/api/#{kyc&.id_proof_back&.url}")
  json.thumb (Rails.env.production? ? kyc&.id_proof_back&.url(:thumb) : "/api/#{kyc&.id_proof_back&.url(:thumb)}")
end
json.profile do
  user = kyc.user
  profile = user.profile
  json.first_name user.first_name
  json.last_name user.last_name
  json.mothers_maiden_name user.mothers_maiden_name
  json.date_of_birth profile.date_of_birth&.strftime('%d-%m-%Y')
  json.employee_id profile.employee_id
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