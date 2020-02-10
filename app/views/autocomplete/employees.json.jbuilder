if @op.success?
  json.array!(@op.paginated_users) do |user|
    json.label user.name
    json.email user.email
    json.employee_id user.employee_id
    json.value user.id
  end
else
  json.array! []
end
