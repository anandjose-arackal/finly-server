class InvoiceLineItemDrop < Drop

  def category
    @object.category.to_liquid
  end

  def gl_code
    @object.category&.gl_code
  end

  def taxable_amount
    @object.taxable_amount&.value || 0
  end

  def billable_amount
    @object.billable_amount&.value || 0
  end

  def tax_amount
    @object.tax_amount
  end

  def net_amount
    @object.net_amount.value
  end

  def cgst?
    @object.parent.gst_type_id == 2
  end

  def sgst?
    @object.parent.gst_type_id == 2
  end

  def igst?
    [nil, 1].include? @object.parent.gst_type_id
  end

  def cgst_amount
    return 0 unless cgst?
    @object.tax_amount&.value / 2 || 0
  end

  def sgst_amount
    return 0 unless sgst?
    @object.tax_amount&.value / 2 || 0
  end

  def igst_amount
    return 0 unless igst?
    @object.tax_amount&.value
  end

  def tax_rate
    @object.tax_rate&.to_liquid
  end

end