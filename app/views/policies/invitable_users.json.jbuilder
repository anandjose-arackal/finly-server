json.array!(@result.invitable_users) do |user|
  json.email user.email
  json.mobile_number user.mobile_number
  json.id user.id
  json.name user.name
end