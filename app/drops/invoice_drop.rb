class InvoiceDrop < Drop

  def invoice_id
    record.invoice_id
  end

  def company
    record.company.to_liquid
  end

  def vendor_location
    record.gstin_location.to_liquid
  end

  def vendor
    record.vendor.to_liquid
  end

  def date
    record.date
  end

  def approved_date
    record.approved_at
  end

  def cost_center
    record.cost_center.to_liquid
  end

  def department
    record.department.to_liquid
  end

  def billing_location
    record.location.to_liquid
  end

  def shipping_location
    record.delivery_location.to_liquid
  end

  def narration
    record.narration
  end

  def invoice_number
    record.invoice_number
  end

  def net_amount
    record.net_amount&.value || 0
  end

  def gross_amount
    record.gross_amount&.value || 0
  end

  def tds_amount
    record.tds_amount.value || 0
  end

  def tds_slab
    record.tds_slab.to_liquid
  end

  def line_items
    record.invoice_items.to_a.map(&:to_liquid)
  end

end