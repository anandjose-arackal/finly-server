if @users && @users.is_a?(ActiveRecord::Relation)
  json.array!(@users.uniq) do |user|
    json.label user.name
    json.value user.id
  end
end