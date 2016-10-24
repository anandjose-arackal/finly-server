json.pending_reimbursement @result.balances[:target_user_pending_reimbursement]
json.pending_money_request @result.balances[:target_user_pending_advance_request]
json.cash_in_hand @result.balances[:target_user_cash_in_hand]
json.wallet_balance @result.balances[:target_user_wallet]
json.card_balance @result.balances[:target_user_card]

json.company_credits 20000
json.current_user_cash_in_card 2000
json.current_user_wallet_balance 13000
#dummy values end here

unless params[:view] == 'personal'
  json.actions do
    @result.actions.each do |key, value|
    # b.actions.each do |key, value|
      json.set! key, (value)
      # puts key, (value[:url] or value[:value])
    end
  end
end