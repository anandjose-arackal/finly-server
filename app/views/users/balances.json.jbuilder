json.balances do
  json.card_balance_credits @result.balances[:card_balance_credits]
  json.bank_transfer_credits @result.balances[:bank_transfer_credits]
  json.finly_money_card_transfer_pocket @result.balances[:finly_money_card_transfer_pocket]
  json.finly_money_bank_transfer_pocket @result.balances[:finly_money_bank_transfer_pocket]
  json.expense_management @result.balances[:expense_management]
  json.disburse @result.balances[:disburse]
  json.vendor_payments @result.balances[:vendor_payments]

  if @result.balances[:cards].present?
    json.cards do
      json.array!(@result.balances[:cards]) do |card|
        json.id card[:id]
        json.balance card[:balance]
        json.type card[:type]
        json.eligibility card[:eligibility]
      end
    end
  end
end