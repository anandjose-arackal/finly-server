if @users
  json.array!(@users) do |user|
    json.label user.name
    json.value user.id
  end
end