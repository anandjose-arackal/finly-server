invoice_item = @result.inventory_item
json.extract! invoice_item, :id, :description, :hsn_sac, :sku, :tax, :discount, :note