json.array! @result.card_assign_requests.each do |card_assign_request|
  json.company do
    company = @result.company_for(card_assign_request)
    json.id company&.id
    json.name company&.name
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
  json.kyc do
    kyc = @result.kyc_for(card_assign_request)
    json.address_proof do
      json.file_type kyc&.file_format(kyc.address_proof)
      json.original kyc&.address_proof&.url
      json.thumb kyc&.address_proof&.url(:thumb)
    end
    json.id_proof do
      json.file_type kyc&.file_format(kyc.id_proof)
      json.original kyc&.id_proof&.url
      json.thumb kyc&.id_proof&.url(:thumb)
    end
  end
  json.actions do
    actions = @result.actions_for(card_assign_request)
    json.approve !!actions[:approve]
    json.reject !!actions[:reject]
    json.mark_as_assigned !!actions[:mark_as_assigned]
    json.mark_as_upgraded !!actions[:mark_as_upgraded]
  end
end