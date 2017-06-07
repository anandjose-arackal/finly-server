json.custom_fields @result&.custom_fields_config&.dig(:manual_expense)

json.currencies do
  json.array!(@result.currencies) do |currency|
    json.id currency.id
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.country currency.country
  end
end

json.categories do
  json.array!(@result.categories) do |category|
    json.extract! category, :id, :name
  end
end