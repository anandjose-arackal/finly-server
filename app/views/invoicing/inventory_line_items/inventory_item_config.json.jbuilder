json.categories do
  json.array! @result.categories
end

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge!(tax_rate.as_json)
  end
end

json.supply_item_types do
  json.array! @result.supply_item_types do |item|
    json.extract! item, :id, :name
  end
end