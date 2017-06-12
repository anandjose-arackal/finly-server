json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp
  json.user transaction.user.name
  json.mobile_number transaction.user.mobile_number
  json.amount transaction.transaction_amount_value
  json.card_no transaction.card.ending_number
end