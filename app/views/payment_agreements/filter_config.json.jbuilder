json.result do
  json.policies do
    json.array!(@result.policies) do |policy|
      json.id policy.id
      json.name policy.name
    end
  end

  json.agreement_types @result.agreement_types
end