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
    return 0 unless cgst?

    record.tax&.to_f / 2 || 0
  end

  attribute :sgst do
    return 0 unless sgst?

    record.tax&.to_f / 2 || 0
  end

  attribute :igst do
    return 0 unless igst?

    record.tax&.to_f
  end

  attribute :cgst_amount, includes: [:tax_amount] do
    return 0 unless cgst?

    record.tax_amount&.value / 2 || 0
  end

  attribute :sgst_amount, includes: [:tax_amount] do
    return 0 unless sgst?

    record.tax_amount&.value / 2 || 0
  end

  attribute :igst_amount, includes: [:tax_amount] do
    return 0 unless igst?

    record.tax_amount&.value
  end
end