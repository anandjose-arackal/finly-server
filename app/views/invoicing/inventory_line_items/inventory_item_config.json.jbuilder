json.categories do
  json.array! @result.categories.leaves.each do |cat|
    json.id cat.id
    json.name cat.full_name
    json.gl_code cat.gl_code
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