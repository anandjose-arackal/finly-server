json.pending_reimbursement @result.balances[:target_user_pending_reimbursement]
json.pending_money_request @result.balances[:target_user_pending_advance_request]
json.cash_in_hand @result.balances[:target_user_cash_in_hand]
json.wallet_balance @result.balances[:target_user_wallet]
json.card_balance @result.balances[:target_user_card]
json.card_eligibility @result.balances[:target_user_card_eligibility]
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