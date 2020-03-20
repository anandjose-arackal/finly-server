class InvoiceLineItemExposure < Exposures::API

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

  def tax_amount
    record.tax_amount
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

  def tax_rate
    record.tax_rate&.to_liquid
  end

end