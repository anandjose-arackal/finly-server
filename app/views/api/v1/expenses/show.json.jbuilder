json.partial! 'expense', expense: @result.expense
json.currencies do
  json.array!(Currency.all) do |currency|
    json.country currency.country
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end

json.tax_rates @result.tax_rates
json.state_codes @result.gst_state_codes