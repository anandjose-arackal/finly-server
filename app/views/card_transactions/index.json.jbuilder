json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp.strftime("%Y  %B  %d - %H:%M:%S")
  json.amount_value transaction.billing_amount_value
  json.currency_symbol transaction.billing_amount.currency.symbol
  json.currency_country_code transaction.billing_amount.currency.country_code
  json.type "Refund"
  json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
  json.id transaction.id
end