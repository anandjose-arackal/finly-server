json.id user.id
json.name user.name
json.mobile_number user.mobile_number
json.email user.email
# json.card do
#   assigned = user.cards.present?
#   json.assigned assigned
#   if assigned
#     card = user.cards.first
#     json.extract! card, :ending_number, :description, :active, :serial_id
#     json.balance do
#       json.value card.balance
#       json.currency do
#         json.extract! Currency.first, :id, :country, :country_code, :symbol
#       end
#     end
#   end
# end

json.card do
  card = user.cards.first rescue nil
  assigned = card.present?
  json.assigned assigned
  if assigned
    json.extract! card, :ending_number, :description, :active, :serial_id, :balance, :available_card_eligibility
    json.disabled_by do
      json.name card.disabled_by_user.name rescue nil
      role_name = nil
      role_name = UserRole.name_for(card.disabled_by_role_id) if card.disabled_by_role_id.present?
      json.role role_name
    end
  end
end

