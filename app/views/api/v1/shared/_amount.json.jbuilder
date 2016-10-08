if amount.present?
  json.value amount.value
  json.currency do
    json.extract! amount.currency, :id, :country, :country_code, :symbol
  end
end