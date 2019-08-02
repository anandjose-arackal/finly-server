json.array!(@result.paginated_users) do |user|
  json.extract! user, :name, :email, :id, :mobile_number
  json.employee_id user.employee_id
  json.cards user.cards
  json.state user.user_state
  json.company_name user.company_name
  json.poc user.point_of_contact
end