json.users do
  json.array!(@result.users) do |user|
    json.extract! user, :name, :email, :id
    json.created_at user.created_at.to_date.strftime("%d %B %y")
    json.state user.user_state
  end
end

json.companies do
  json.array! @result.companies.each do |company|
    json.extract! company, :id, :name
  end
end