json.array!(@result.paginated_users) do |user|
  json.extract! user, :name, :email, :id, :mobile_number
  json.cards user.cards
  json.state user.user_state
  json.company_name user.company_name
  json.poc user.point_of_contact
end