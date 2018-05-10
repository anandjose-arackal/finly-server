json.array!(@result) do |user|
  json.id user.id
  json.name user.name
  json.label user.name
  json.value user.id
  json.email user.email
  json.mobile_number user.mobile_number
end

