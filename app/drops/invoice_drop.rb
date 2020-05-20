class InvoiceDrop < Drop

  def invoice_id
    @object.invoice_id
  end

  def company
    @object.company.to_liquid
  end

  def vendor_location
    @object.gstin_location.to_liquid
  end

  def vendor
    @object.vendor.to_liquid
  end

  def date
    @object.date
  end

  def approved_date
    @object.approved_at
  end

  def cost_center
    @object.cost_center.to_liquid
  end

  def department
    @object.department.to_liquid
  end

  def billing_location
    @object.location.to_liquid
  end

  def shipping_location
    @object.delivery_location.to_liquid
  end

  def narration
    @object.narration
  end

  def invoice_number
    @object.invoice_number
  end

  def net_amount
    @object.net_amount&.value || 0
  end

  def balance_due
    @object.balance_due&.value || 0
  end

  def gross_amount
    @object.gross_amount&.value || 0
  end

  def tds_amount
    @object.tds_amount.value || 0
  end

  def tds_slab
    @object.tds_slab.to_liquid
  end

  def roundoff_amount
    @object.roundoff_amount || -0
  end

  def line_items
    @object.invoice_items.to_a.map(&:to_liquid)
  end

  def transaction_period_from
    @object.transaction_service_period_from
  end

  def transaction_period_to
    @object.transaction_service_period_to
  end

end