json.array!(@result.users) do |user|
  json.extract! user, :name, :email, :id
  json.created_at user.created_at.to_date.strftime("%d %B %y")
  json.state user.user_state
end