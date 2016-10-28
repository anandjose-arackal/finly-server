json.merge! @result.balances

if @result.target_user.present?
  json.target_user_card_details do
    card = @result.target_user.cards.first rescue nil
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
end
if @result.user.present?
  json.current_user_card_details do
    card = @result.user.cards.first rescue nil
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
end