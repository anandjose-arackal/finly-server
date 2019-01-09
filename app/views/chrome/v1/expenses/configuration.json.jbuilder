json.custom_fields @result&.custom_fields_config&.dig(:manual_expense)

json.categories do
  cat_result = Company::Configuration::Category::Index.(@result.user, @result.params)
  if cat_result.success?
    categories = cat_result.mobile_optimized_categories
  else
    categories = []
  end
  json.array!(categories) do |category|
    json.extract! category, :id, :name
  end
end

json.currencies do
  json.array!(@result.currencies) do |currency|
    json.id currency.id
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.country currency.country
  end
end

json.balances do
  json.cash_on_hand @result.cash_on_hand
end