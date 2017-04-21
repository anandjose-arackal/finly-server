json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp
  json.amount_value transaction.billing_amount_value
  json.type "Reversal"
  json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
end