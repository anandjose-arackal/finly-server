class ItemExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :sku, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :description, record_attribute: true
  attribute :category, record_attribute: true, exposure: true, includes: [:category]
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :note, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true
  attribute :item_code, record_attribute: true
  attribute :account, record_attribute: true
  attribute :scope, includes: [:supply_item_type] do
    if record.supply_item_type&.name == "po_non_po_item"
      "All"
    else
      record.supply_item_type&.name&.gsub("_item", "")&.titleize
    end
  end
  attribute :deleted_at, record_attribute: true
  attribute :product_type, includes: [:product_type] do
    record.product_type&.name&.titleize
  end
  attribute :item_number, record_attribute: true
  attribute :unit_of_measurement, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :active, record_attribute: true
  attribute :expense_type, includes: [:item_expense_type] do
    record.item_expense_type&.name
  end
  attribute :tds_applicable, record_attribute: true
  attribute :hsn_sac, record_attribute: true

end
