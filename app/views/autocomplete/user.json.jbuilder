if @users && @users.is_a?(ActiveRecord::Relation)
  json.array!(@users.uniq) do |user|
    json.label user.name
    json.email user.email
    json.employee_id user.employee_id
    json.value user.id
  end
end