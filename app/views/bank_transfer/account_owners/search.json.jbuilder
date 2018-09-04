json.array!(@result.account_owners) do |account_owner|
  json.label account_owner.name
  json.value account_owner.id
end