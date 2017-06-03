json.id @result.card.id
json.serial_id @result.card.serial_id
json.active @result.card.active
json.ending_number @result.card.ending_number
json.description @result.card.description
json.balance @result.card_balance
json.eligibility @result.card_eligibility
if @result.card.disabled_by_user
  json.disabled_by do
    user = @result.card.disabled_by_user
    json.user do
      json.id user&.id
      json.name user&.name
    end
    json.role do
      json.id @result.card.disabled_by_role_id
      json.name UserRole.name_for(@result.card.disabled_by_role_id)
    end
  end
else
  json.disabled_by nil
end