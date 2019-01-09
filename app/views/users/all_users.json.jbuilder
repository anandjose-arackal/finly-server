json.array!(@result.users) do |user|
  json.email user.email
  json.name user.name
  json.mobile_number user.mobile_number
  json.active user.active
end