json.id user.id
json.name user.name
json.mobile_number user.mobile_number
json.email user.email
json.finly_money do
  json.id user.wallet.id
  json.balance user.wallet.balance
end
json.cards do
  json.array! user.cards do |card|
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
  end
end
json.roles do
  json.admin user.admin?
  json.finance_manager user.finance_manager?
end