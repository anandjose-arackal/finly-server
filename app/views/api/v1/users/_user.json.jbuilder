json.id user.id
json.name user.name
json.mobile_number user.mobile_number
json.email user.email
json.card do
  assigned = @result.selected_user.cards.present?
  json.assigned assigned
  if assigned
    card = @result.selected_user.cards.first
    json.extract! card, :ending_number, :description, :active, :serial_id
    json.balance do
      json.value card.balance
      json.currency do
        json.extract! Currency.first, :id, :country, :country_code, :symbol
      end
    end
  end
end