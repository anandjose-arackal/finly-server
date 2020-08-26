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

  attribute :custom_fields, includes: [{ parent: { custom_fields: [:field_configuration, :value] } }] do
    record.parent.custom_fields
  end
end
