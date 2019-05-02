json.categories do
  json.array! @result.categories do |category|
    json.merge!(category.as_json(tree: true))
  end
end

json.filter_categories do
  json.array! @result.filter_categories do |category|
    json.merge!(category.as_json)
  end
end

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge!(tax_rate.as_json)
  end
end

json.supply_item_types do
  json.array! @result.supply_item_types do |item|
    json.merge! item.as_json
  end
end