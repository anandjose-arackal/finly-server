json.categories do
  json.array! @result.categories
end

json.tax_rates do
  json.array! @result.tax_rates
end