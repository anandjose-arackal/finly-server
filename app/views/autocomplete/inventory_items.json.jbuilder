json.array!(@result.search_results) do |inventory_item|
  # json.extract! inventory_item, :description
  json.value inventory_item.id
  json.label inventory_item.description
  json.item_number inventory_item.item_number
  # json.extract! inventory_item, :id, :description, :hsn_sac, :category_id, :rate, :tax, :discount, :sku, :note
end