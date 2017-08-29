json.array!(@result.paginated_users) do |user|
  json.extract! user, :name, :email, :id
  json.created_at user.created_at.to_date.strftime("%d %B %y")
  json.state user.user_state
  json.company_name user.company_name
  json.poc user.point_of_contact
end