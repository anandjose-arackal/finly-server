json.array!(@result.transactions) do |transaction|
  json.timestamp transaction.transaction_timestamp.strftime("%Y  %B  %d - %H:%M:%S")
  json.user do
    json.name transaction.user.name
    json.mobile transaction.user.mobile_number
  end

  json.currency_symbol transaction.transaction_amount.currency.symbol
  json.currency_country_code transaction.transaction_amount.currency_country_code

  json.amount_value transaction.transaction_amount_value
  json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
end