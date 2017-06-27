json.id card.id
json.serial_id card.serial_id
json.active card.active
json.ending_number card.ending_number
json.description card.description
json.balance card.card_balance
json.eligibility card.card_eligibility
if card.disabled_by_user
  json.disabled_by do
    user = card.disabled_by_user
    json.user do
      json.id user&.id
      json.name user&.name
    end
    json.role do
      json.id card.disabled_by_role_id
      json.name UserRole.name_for(card.disabled_by_role_id)
    end
  end
else
  json.disabled_by nil
end
json.assigned card.user_id.present?
if card.user_id.present?
  json.assigned_to_user do
    json.id card.user.id
    json.name card.user.name
    json.mobile_number card.user.mobile_number
    json.email card.user.email
  end
end