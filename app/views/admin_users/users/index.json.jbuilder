json.array!(@result.users) do |user|
  json.extract! user, :name
  json.created_at user.created_at.to_date.strftime("%d %B %y")
end