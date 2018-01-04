json.array!(@result.paginated_users) do |user|
  json.extract! user, :name, :email, :id
  # json.serial_number user.cards.pluck(:proxy).join(",")
  json.cards do
    json.array!(user.cards) do |card|
      json.card card
    end
  end
  json.state user.user_state
  json.company_name user.company_name
  json.poc user.point_of_contact
end