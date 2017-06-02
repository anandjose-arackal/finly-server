json.extract! money_request, :id, :name, :submitted_at, :memo, :required_by_date
json.status do
  json.id money_request.status_id
  json.name @result.status_name(money_request)
end
json.user do
  json.id money_request.user_id
  json.name money_request.user.name
  json.email money_request.user.email
  json.mobile_number money_request.user.mobile_number
end
json.policy do
  json.id money_request.policy_id
  json.name money_request.policy.name rescue nil
end
json.payment_mode do
  json.id money_request.payment_mode_id
  json.name money_request.payment_mode.name rescue nil
end
json.total_amount do
  json.value money_request.total_amount
  json.currency do
    json.extract! Currency.first, :id, :country, :country_code, :symbol
  end
end