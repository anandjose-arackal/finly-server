json.pending_reimbursement @result.selected_user.balance_sheet.pending_reimbursement.value
json.cash_in_hand @result.selected_user.balance_sheet.cash_in_hand.value
json.pending_money_request @result.selected_user.balance_sheet.pending_advance.value
json.wallet_balance @result.selected_user.wallet.balance_value
# Todo dummy values
json.cash_in_card 200

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