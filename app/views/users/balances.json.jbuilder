json.balances do
  json.card_balance_credits @result.balances[:card_balance_credits]
  json.bank_transfer_credits @result.balances[:bank_transfer_credits]
  json.finly_money_card_transfer_pocket @result.balances[:finly_money_card_transfer_pocket]
  json.finly_money_bank_transfer_pocket @result.balances[:finly_money_bank_transfer_pocket]

  json.cards do
    json.array!(@result.balances[:cards]) do |card|

    end
  end
end