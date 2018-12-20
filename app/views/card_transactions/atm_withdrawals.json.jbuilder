json.result do

  json.array!(@result.paginated_transactions) do |transaction|
    json.timestamp transaction.transaction_timestamp.strftime("%Y  %B  %d - %H:%M:%S")
    json.user do
      json.name transaction.user.name
      json.mobile transaction.user.mobile_number
    end

    json.currency_symbol transaction.transaction_amount.currency.symbol
    json.currency_country_code transaction.transaction_amount.currency_country_code

    json.amount_value transaction.transaction_amount_value
    json.proxy transaction.serial_id
  end
end

json.count @result.count