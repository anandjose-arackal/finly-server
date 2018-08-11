json.array!(@result.pockets) do |pocket|
  json.id pocket.name
  json.name pocket.name
  currency = pocket.base_currency
  json.base_currency do
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end