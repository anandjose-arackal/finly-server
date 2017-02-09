json.pending_reimbursement @result.balances[:target_user_approved_reports]
json.pending_money_request @result.balances[:target_user_pending_advance_request]
json.cash_in_hand @result.balances[:target_user_cash_in_hand]
json.wallet_balance @result.balances[:target_user_wallet]
json.card_balance @result.balances[:target_user_card]
json.card_eligibility @result.balances[:target_user_card_eligibility]
json.target_user_card do
  card = @result.selected_user.cards.first rescue nil
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

allow_card_transfer = false
if @result.selected_user.cards.present?
    allow_card_transfer = @result.selected_user.cards.first.active
end
json.allow_card_transfer allow_card_transfer

unless params[:view] == 'personal'
  json.actions do
    @result.actions.each do |key, value|
    # b.actions.each do |key, value|
      json.set! key, (value)
      # puts key, (value[:url] or value[:value])
    end
  end
end