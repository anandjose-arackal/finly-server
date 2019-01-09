json.policies @result.policies.each do |policy|
  json.id policy.id
  json.name policy.name
  json.custom_fields @result.custom_fields_for(policy)
end