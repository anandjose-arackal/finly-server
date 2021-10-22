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

  attribute :department, includes: [:department], exposure: true do
    (record.purchase_order.cost_allocation_items ? record.department : record.purchase_order.department)
  end

  attribute :cost_center, includes: [:cost_center], exposure: true do
    (record.purchase_order.cost_allocation_items ? record.cost_center : record.purchase_order.cost_center)
  end

  attribute :accepted_quantity, record_attribute: false,exposure: false do
    (record.inventory_line_item&.product_type_id ==  ProductType.id_for(:goods) ? record.accepted : "")
  end

  attribute :billed_amount, record_attribute: false,exposure: false do
    (record.inventory_line_item&.product_type_id ==  ProductType.id_for(:service) ? record.previously_billed_amount : "")
  end

  attribute :pending_grn_quantity, record_attribute: false,exposure: false do
    (record.inventory_line_item&.product_type_id ==  ProductType.id_for(:goods) ? (record.quantity - record.accepted) : "") rescue ""
  end

  attribute :pending_billed_amount, record_attribute: false,exposure: false do
    (record.inventory_line_item&.product_type_id ==  ProductType.id_for(:service) ? (record.taxable_amount&.value - record.previously_billed_amount)&.to_f&.round(2) : "") rescue ""
  end

  attribute :invoiced_amount, record_attribute: false,exposure: false do
    record.invoiced_total_amount rescue ""
  end

  attribute :pending_invoice_amount, record_attribute: false,exposure: false do
    (record.invoiced_total_amount - record.taxable_amount&.value).abs rescue ""
  end


end