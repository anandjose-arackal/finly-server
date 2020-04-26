class GeneralInvoiceExposure < Exposures::API

  attribute :id, record_attribute: true
  # attribute :template_invoice, record_attribute: true, exposure: true # todo no idea what this field is, hence commented
  attribute :created_by, record_attribute: true, exposure: true
  attribute :invoice_id, record_attribute: true
  attribute :invoice_type, record_attribute: true, exposure: true
  attribute :company, record_attribute: true, exposure: true, includes: [:company]
  attribute :gstin_location, record_attribute: true, exposure: true, includes: [:gstin_location]
  attribute :vendor_location, record_attribute: true, exposure: true, includes: [:vendor_location]
  attribute :vendor, record_attribute: true, exposure: true, includes: [:vendor]
  attribute :payment_agreement, record_attribute: true, exposure: true, includes: [:payment_agreement]
  attribute :start_date, record_attribute: true
  attribute :end_date, record_attribute: true
  attribute :date, record_attribute: true
  attribute :due_date, record_attribute: true
  attribute :due_in_days do
    next unless record.due_date.present?

    days = record.due_date - Date.today
    next if InwardInvoiceStatus.ids_for(:paid, :closed, :voided).include?(record.invoice_status_id)

    if days < 0
      "Overdue by #{days.abs.to_i} days"
    else
      "#{days.to_i} days"
    end
  end
  attribute :upcoming_in_days do

  end
  attribute :start_date do

  end
  attribute :end_date do

  end
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :billing_location, record_attribute: :location, exposure: true, includes: [:location]
  attribute :shipping_location, record_attribute: :delivery_location, exposure: true, includes: [:delivery_location]
  attribute :narration, record_attribute: true
  attribute :invoice_number, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :gross_amount, record_attribute: true, exposure: true, includes: [:gross_amount]
  attribute :gross_amount_value, includes: [:gross_amount] do
    record.gross_amount&.value || 0
  end
  attribute :discount_amount, record_attribute: true, exposure: true, includes: [:discount_amount]
  attribute :discount_amount_value, includes: [:discount_amount] do
    record.discount_amount&.value || 0
  end
  attribute :tax_amount, record_attribute: true, exposure: true, includes: [:tax_amount]
  attribute :tax_type, record_attribute: true, exposure: true
  attribute :tax_type_id, record_attribute: true
  attribute :tax_type_name do
    case record.tax_type_id
    when 1
      'CGST + IGST'
    when 2
      'IGST'
    else
      nil
    end
  end
  attribute :cgst_amount do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      (record.tax_amount&.value || 0)/2
    when GstType.id_for(:igst)
      0
    else
      0
    end
  end
  attribute :sgst_amount do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      cgst
    when GstType.id_for(:igst)
      0
    end
  end
  attribute :igst_amount do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      0
    when GstType.id_for(:igst)
      record.tax_amount&.value || 0
    end
  end
  attribute :freight_amount, record_attribute: true, exposure: true, includes: [:freight_amount]
  attribute :freight_amount_value, includes: [:freight_amount] do
    record.freight_amount&.value || 0
  end
  attribute :tds_slab, record_attribute: true, exposure: true, includes: [:tds_slab]
  # attribute :tds_rate, record_attribute: true
  attribute :tds_amount, exposure: true, record_attribute: true, includes: [:tds_amount]
  attribute :tds_amount_value, includes: [:tds_amount] do
    record.tds_amount&.value || 0
  end
  attribute :net_amount, exposure: true, record_attribute: true, includes: [:net_amount]
  attribute :net_amount_value, includes: [:net_amount] do
    record.net_amount&.value || 0
  end
  attribute :roundoff_amount, record_attribute: true
  attribute :advance_amount, record_attribute: true, exposure: true
  attribute :balance_due, includes: [:balance_due], record_attribute: true, exposure: true
  attribute :balance_due_value, includes: [:balance_due] do
    record.balance_due&.value || 0
  end

  # Fixme: Performance incase the number of line items it high
  attribute :line_items, record_attribute: :invoice_items, exposure: true, includes: [:line_items]
  attribute :cost_allocation_items, record_attribute: true
  # attribute :status, record_attribute: true, exposure: true, includes: [:status]

end