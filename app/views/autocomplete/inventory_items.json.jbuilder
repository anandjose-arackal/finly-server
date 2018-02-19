json.array!(@result.search_results) do |inventory_item|
  json.extract! inventory_item, :id, :description, :hsn_sac, :category_id, :rate, :tax, :discount, :sku, :note
end