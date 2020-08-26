class InvoiceLineItemExposure < Exposures::API

  attribute :invoice, record_attribute: :parent, exposure: true, includes: [:parent]
  attribute :description, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true, includes: [:tax_rate]
  attribute :itc_qualified, includes: [{ parent: { items: :tax_rate } }] do
    record.parent.items.map {|i| i.tax_rate.present?}.compact.present?
  end
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :hsn_sac, record_attribute: true
  attribute :country, includes: [{ amount: :currency }] do
    record.amount&.currency&.country
  end
  attribute :tax_amount, record_attribute: true, exposure: true, includes: [:tax_amount]
  attribute :tax_amount_value, includes: [:tax_amount] do
    record.tax_amount&.value || 0
  end

  attribute :category, record_attribute: true, exposure: true, includes: [:category]
  attribute :gl_code, includes: [:category] do
    record.category&.gl_code
  end

  attribute :taxable_amount, includes: [:taxable_amount] do
    record.taxable_amount&.value || 0
  end

  attribute :billable_amount, includes: [:billable_amount] do
    record.billable_amount&.value || 0
  end

  attribute :net_amount, includes: [:net_amount] do
    record.net_amount.value
  end

  attribute :cgst?, includes: [:parent] do
    record.parent.gst_type_id == 2
  end

  attribute :sgst?, includes: [:parent] do
    record.parent.gst_type_id == 2
  end

  attribute :igst?, includes: [:parent] do
    [nil, 1].include? record.parent.gst_type_id
  end

  attribute :cgst do
    if cgst?
      (record.tax&.to_f || 0) / 2
    else
      0
    end
  end

  attribute :sgst do
    if sgst?
      (record.tax&.to_f || 0) / 2
    else
      0
    end
  end

  attribute :igst do
    if igst?
      record.tax&.to_f
    else
      0
    end
  end

  attribute :cgst_amount, includes: [:tax_amount] do
    if cgst?
      (record.tax_amount&.value || 0) / 2
    else
      0
    end
  end

  attribute :sgst_amount, includes: [:tax_amount] do
    if sgst?
      (record.tax_amount&.value || 0) / 2
    else
      0
    end
  end

  attribute :igst_amount, includes: [:tax_amount] do
    if igst?
      record.tax_amount&.value
    else
      0
    end
  end

  attribute :po_date, includes: [{purchase_order_item: :purchase_order}] do
    record.purchase_order_item&.purchase_order&.created_at
  end

  attribute :tds_nature, includes: [{ parent: :tds_slab }] do
    if record.tds_applicable
      record.parent.tds_slab&.name
    else
      ''
    end
  end

  attribute :tds_percentage do
    if record.tds_applicable
      record.parent.tds_slab&.tds || 0.0
    else
      0.0
    end
  end

  attribute :tds_amount, includes: [:billable_amount, :taxable_amount] do
    if record.tds_applicable
      record.tds_amount || 0.0
    else
      0.0
    end
  end

  attribute :quantity, record_attribute: true
  attribute :unit_of_measurement, record_attribute: true
  attribute :cost_center, record_attribute: true, exposure: true

  attribute :discount_amount_value, includes: [:discount_amount] do
    record.discount_amount&.value || 0
  end

  attribute :item_code do
    record.inventory_line_item&.item_code
  end

  attribute :total_amount, includes: [:parent, :amount, :inventory_line_item, :billable_amount, :amount] do
    if record.parent&.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
      record.amount&.value.to_f
    elsif record.inventory_line_item&.product_type_id == ProductType.id_for(:service)
      record.billable_amount&.value.to_f
    else
      record.amount&.value.to_f
    end
  end

  attribute :custom_fields, includes: [{ parent: { custom_fields: [:field_configuration, :value] } }] do
    record.parent.custom_fields
  end
end
