json.policies do
  json.array!(@result.policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end

json.user_roles @result.user_roles



