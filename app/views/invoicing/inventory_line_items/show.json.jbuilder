json.result do
  json.summary do
    json.extract! @result.inventory_item, :id, :tax, :discount, :hsn_sac, :company_id, :sku, :rate, :description, :category_id, :note, :tax_rate_id, :item_code, :account, :supply_item_type_id
  end
  if @result.inventory_item.artifacts.present?
    json.attachments do
      json.array!(@result.inventory_item.artifacts) do |artifact|
        json.attachment = artifact&.attachment&.url 
      end
    end
  end
end