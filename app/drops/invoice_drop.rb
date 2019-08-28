class InvoiceDrop < Drop

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

  def line_items
    @object.invoice_items.to_a.map(&:to_liquid)
  end

end