json.result do
  json.array! @result.user_delegates do |user|
    json.name user.name
    json.id user.id
    json.count @result.user_delegates.count
  end
end