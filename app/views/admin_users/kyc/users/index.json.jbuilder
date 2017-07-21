json.array! @result.individual_kycs.each do |kyc|
  json.id kyc.id
  json.received_date DateUtils.date_formatted kyc.submitted_on
  json.company do
    company = @result.company_for(kyc)
    json.id company&.id
    json.name company&.name&.humanize
  end
  json.user do
    user = kyc.user
    json.email user&.email
    json.mobile_number user&.mobile_number
    json.first_name user&.first_name
    json.last_name user&.last_name
    json.mothers_maiden_name user&.mothers_maiden_name
    json.date_of_birth DateUtils.date_formatted user&.profile&.date_of_birth
    json.gender user&.profile&.gender
    json.address_1 user&.profile&.address_1
    json.address_2 user&.profile&.address_1
    json.city user&.profile&.city
    json.state user&.profile&.state&.name
    json.country 'India'
    json.pin_code user&.profile&.pin_code
    json.nationality 'Indian'
    json.salutation_status user&.profile&.salutation_status
  end
  cards = kyc.user.cards
  json.cards do
    json.array! cards do |card|
      json.proxy card.proxy
    end
  end
  json.status do
    json.name kyc.kyc_status.name
  end
  json.actions do
    actions = @result.actions_for(kyc)
    json.approve !!actions[:approve]
    json.reject !!actions[:reject]
    json.mark_as_upgraded !!actions[:mark_as_upgraded]
  end
  json.kyc do
    json.id_number kyc&.kyc_number
    if kyc&.type.blank?
      json.type nil
    else
      json.type do
        json.id kyc.type.id
        json.name kyc.type.name
      end
    end
    if kyc&.kyc_file_1.blank?
      json.file_1 nil
    else
      json.file_1 do
        json.original kyc&.kyc_file_1&.url(:normal)
        json.thumb kyc&.kyc_file_1&.url(:thumb)
      end
    end
    if kyc&.kyc_file_2.blank?
      json.file_2 nil
    else
      json.file_2 do
        json.original kyc&.kyc_file_2&.url(:normal)
        json.thumb kyc&.kyc_file_2&.url(:thumb)
      end
    end
  end
end