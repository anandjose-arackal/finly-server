json.array!(@result.paginated_users) do |user|
  json.extract! user, :name, :email, :id
  json.serial_number user.cards.pluck(:proxy).join(",")
  json.state user.user_state
  json.company_name user.company_name
  json.poc user.point_of_contact
end