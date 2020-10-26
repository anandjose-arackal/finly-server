payment = result.payment

json.payment_details do
  json.id payment.id
  json.status payment&.status&.name
  json.payment_date payment&.processed_at.to_s
  json.utr payment&.utr&.to_s
end

json.vendor_details do
  if payment.receiving_account&.is_a?(BbpsBiller)
    json.name payment.receiving_account&.biller_name
    json.editable false # because a bbps bill can never be edited from the payment ticket screen
  elsif payment.receiving_account&.account_owner&.is_a?(YesBankVendor)
    json.name payment.receiving_account&.account_owner&.display_name
    json.owner_business_name payment&.receiving_account&.account_owner&.business_name
    json.trade_name payment&.receiving_account&.account_owner&.trade_name
  else
    json.name payment.receiving_account&.account_owner&.name
  end
end

json.vendor_account_details do
  json.name payment.receiving_account&.name
  json.number payment&.receiving_account&.account_number.to_s
  json.ifsc payment&.receiving_account&.ifsc.to_s
  if payment.receiving_user.is_a?(User) || payment.receiving_user.is_a?(BbpsBillerSubscription) || payment.receiving_user.authorized
    json.beneficiary_type "authorized"
  else
    json.beneficiary_type "unauthorized"
  end
end