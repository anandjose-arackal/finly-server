json.array!(@result.inventory_line_items) do |item|
  json.extract! item, :id, :hsn_sac, :category_id, :rate, :description, :discount, :sku, :discount, :tax
  json.category_name item.category&.name
end