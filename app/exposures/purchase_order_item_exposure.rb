class PurchaseOrderItemExposure < Exposures::API
  attribute :id, record_attribute: true
  attribute :purchase_order, record_attribute: true, exposure: true
  attribute :inventory_line_item, record_attribute: true, exposure: true
  attribute :description, record_attribute: true
  attribute :comment, record_attribute: true
  attribute :category, record_attribute: true, exposure: true
  attribute :hsn_sac, record_attribute: true
  attribute :quantity, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true
  attribute :tax_amount, record_attribute: true, exposure: true
  attribute :total_amount, record_attribute: true, exposure: true
  attribute :discount, record_attribute: true
  attribute :discount_amount, record_attribute: true, exposure: true
end