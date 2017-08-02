json.array! @result.card_assign_requests.each do |card_assign_request|
  json.id card_assign_request.id
  json.received_date DateUtils.date_formatted card_assign_request.created_at
  json.company do
    company = @result.company_for(card_assign_request)
    json.id company&.id
    json.name company&.name&.humanize
  end
  json.user do
    user = card_assign_request.card_owner
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
    json.state_id user&.profile&.state&.id
    json.country 'India'
    json.pin_code user&.profile&.pin_code
    json.nationality 'Indian'
    json.salutation_status user&.profile&.salutation_status
  end
  json.card do
    card = card_assign_request.card
    json.proxy card.proxy
  end
  json.status do
    json.name card_assign_request.status.name
  end
  json.actions do
    actions = @result.actions_for(card_assign_request)
    json.approve !!actions[:approve]
    json.reject !!actions[:reject]
    json.mark_as_assigned !!actions[:mark_as_assigned]
    json.mark_as_upgraded !!actions[:mark_as_upgraded]
  end
  json.kyc do
    kyc = @result.kyc_for(card_assign_request)
    unless [KycStatus.id_for(:submitted), KycStatus.id_for(:retracted), KycStatus.id_for(:processing), KycStatus.id_for(:approved), KycStatus.id_for(:completed)].include? kyc.kyc_status_id
      kyc = nil
    end
    json.id_number kyc&.kyc_number
    if kyc&.type.blank?
      json.type nil
    else
      json.type do
        json.id kyc.type.id
        json.name kyc.type.name.humanize
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
  json.tracks do
    json.array! card_assign_request.tracks do |track|
      json.user do
        json.name track.action_resource&.name
      end
      json.datetime DateUtils.datetime_formatted track.created_at
      json.message track.message
    end
  end
end