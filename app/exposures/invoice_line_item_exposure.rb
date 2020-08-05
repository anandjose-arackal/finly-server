class InvoiceLineItemExposure < Exposures::API

  attribute :invoice, record_attribute: :parent, exposure: true, includes: [:parent]
  attribute :description, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true, includes: [:tax_rate]
  attribute :itc_qualified do
    record.parent.items.map {|i| i.tax_rate.present?}.compact.present?
  end
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :hsn_sac, record_attribute: true
  attribute :country, includes: [:amount] do
    record.amount&.currency&.country
  end
  attribute :tax_amount, record_attribute: true, exposure: true, includes: [:tax_amount]

  def category
    record.category.to_liquid
  end

  def gl_code
    record.category&.gl_code
  end

  def taxable_amount
    record.taxable_amount&.value || 0
  end

  def billable_amount
    record.billable_amount&.value || 0
  end

  def net_amount
    record.net_amount.value
  end

  def cgst?
    record.parent.gst_type_id == 2
  end

  def sgst?
    record.parent.gst_type_id == 2
  end

  def igst?
    [nil, 1].include? record.parent.gst_type_id
  end

  def cgst
    return 0 unless cgst?
    record.tax&.to_f / 2 || 0
  end

  def sgst
    return 0 unless sgst?
    record.tax&.to_f / 2 || 0
  end

  def igst
    return 0 unless igst?
    record.tax&.to_f
  end

  def cgst_amount
    return 0 unless cgst?
    record.tax_amount&.value / 2 || 0
  end

  def sgst_amount
    return 0 unless sgst?
    record.tax_amount&.value / 2 || 0
  end

  def igst_amount
    return 0 unless igst?
    record.tax_amount&.value
  end

end