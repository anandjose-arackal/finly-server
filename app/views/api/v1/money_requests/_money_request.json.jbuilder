json.extract! money_request, :id, :name, :submitted_at, :memo, :required_by_date
json.status do
  json.id money_request.status_id
  json.name money_request.status.name
end
json.user do
  json.id money_request.user_id
  json.name money_request.user.name
end
json.policy do
  json.id money_request.policy_id
  json.name money_request.policy.name rescue nil
end
json.payment_mode do
  json.id = money_request.payment_mode_id
  json.name = money_request.payment_mode.name rescue nil
end