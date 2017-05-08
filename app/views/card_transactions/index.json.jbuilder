json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp.strftime("%Y  %B  %d - %H:%M:%S")
  json.amount_value transaction.billing_amount_value
  json.type "Refund"
  json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
  json.id transaction.id
end