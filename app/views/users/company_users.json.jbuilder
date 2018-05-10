json.array!(@result) do |user|
  json.id user.id
  json.name user.name
end