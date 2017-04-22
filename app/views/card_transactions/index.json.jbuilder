json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp
  json.amount_value transaction.billing_amount_value
  json.type "Refund"
  json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
  json.id transaction.id
end