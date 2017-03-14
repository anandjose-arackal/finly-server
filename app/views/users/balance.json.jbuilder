json.merge! @result.balances

if @result.target_user.present?
  json.target_user_card_details do
    target_user_cards = (@result.balances[:target_user_card] or [])
    json.array! target_user_cards.each do |card_hash|
      card = card_hash[:card]
      json.extract! card, :ending_number, :description, :active, :serial_id
      view_balance = card_hash[:program][:view_balance]
      view_eligibility = card_hash[:program][:view_eligibility]
      json.view_balance view_balance
      json.view_eligibility view_eligibility
      json.balance card_hash[:balance]
      json.eligibility card_hash[:eligibility]
      json.disabled_by do
        json.name (card.disabled_by_user.name rescue nil)
        role_name = nil
        role_name = UserRole.name_for(card.disabled_by_role_id) if card.disabled_by_role_id.present?
        json.role role_name
      end
    end
  end
end

if @result.user.present?
  json.current_user_card_details do
    current_user_cards = (@result.balances[:current_user_card] or [])
    json.array! current_user_cards.each do |card_hash|
      card = card_hash[:card]
      json.extract! card, :ending_number, :description, :active, :serial_id
      view_balance = card_hash[:program][:view_balance]
      view_eligibility = card_hash[:program][:view_eligibility]
      json.view_balance view_balance
      json.view_eligibility view_eligibility
      json.balance card_hash[:balance]
      json.eligibility card_hash[:eligibility]
      json.disabled_by do
        json.name (card.disabled_by_user.name rescue nil)
        role_name = nil
        role_name = UserRole.name_for(card.disabled_by_role_id) if card.disabled_by_role_id.present?
        json.role role_name
      end
    end
  end
end

# if @result.user.present?
#   json.current_user_card_details do
#     card = @result.user.cards.first rescue nil
#     assigned = card.present?
#     json.assigned assigned
#     if assigned
#       json.extract! card, :ending_number, :description, :active, :serial_id, :balance, :available_card_eligibility
#       json.disabled_by do
#         json.name card.disabled_by_user.name rescue nil
#         role_name = nil
#         role_name = UserRole.name_for(card.disabled_by_role_id) if card.disabled_by_role_id.present?
#         json.role role_name
#       end
#     end
#   end
# end