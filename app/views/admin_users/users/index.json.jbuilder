json.array!(@result.users) do |user|
  json.extract! user, :name, :created_at
end