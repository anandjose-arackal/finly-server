json.array! @result.card_assign_requests.each do |card_assign_request|
  json.id card_assign_request.id
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
    json.address_1 user&.profile&.address_1
    json.address_2 user&.profile&.address_1
    json.city user&.profile&.city
    json.state user&.profile&.state&.name
    json.pin_code user&.profile&.pin_code
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
        json.original kyc&.kyc_file_1&.url
        json.thumb kyc&.kyc_file_2&.url(:thumb)
      end
    end
    if kyc&.kyc_file_2.blank?
      json.file_2 nil
    else
      json.file_2 do
        json.original kyc&.kyc_file_2&.url
        json.thumb kyc&.kyc_file_2&.url(:thumb)
      end
    end
  end
end