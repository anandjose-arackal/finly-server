json.array!(@result.policies) do |policy|
  json.id policy.id
  json.name policy.name
end