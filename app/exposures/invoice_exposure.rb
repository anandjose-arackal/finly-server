class InvoiceExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :procurement_id, record_attribute: true
  attribute :invoice_id, record_attribute: true
  attribute :invoice_type, record_attribute: true, exposure: true
  attribute :company, record_attribute: true, exposure: true, includes: [:company]
  attribute :gstin_location, record_attribute: true, exposure: true, includes: [:gstin_location]
  attribute :vendor_location, record_attribute: true, exposure: true, includes: [:vendor_location]
  attribute :vendor, record_attribute: true, exposure: true, includes: [:vendor]
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
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :approved_at, record_attribute: true
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :billing_location, record_attribute: :location, exposure: true, includes: [:location]
  attribute :shipping_location, record_attribute: :delivery_location, exposure: true, includes: [:delivery_location]
  attribute :narration, record_attribute: true
  attribute :invoice_number, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :policy, exposure: true, record_attribute: true, includes: [:policy]
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
      (record.tax_amount&.value || 0)/2
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
  attribute :tds_rate, record_attribute: true
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
    record.balance_payable&.value || 0
  end
  attribute :paid_amount_value, includes: [:balance_due, {successful_payments: :amount}] do
    record.paid_amount_value || 0
  end
  attribute :balance_payable_value, includes: [:balance_due, {successful_payments: :amount}] do
    record.balance_payable || 0
  end

  # Fixme: Performance incase the number of line items it high
  attribute :line_items, record_attribute: :invoice_items, exposure: true, includes: [:line_items]

  attribute :po_number, includes: [{procurement: :purchase_order}] do
    record&.procurement&.purchase_order&.po_number
  end
  attribute :cost_allocation_items, record_attribute: true
  attribute :status, record_attribute: true, exposure: true, includes: [:status]

  # def vendor_ref_num(invoice_line_item)
  #   invoice_line_item.parent&.vendor_id
  # end
  #
  # def total_tax(invoice_line_item)
  #   invoice_line_item.tax_amount&.value
  # end
  #
  # def finly_ref_no(invoice_line_item)
  #   invoice_line_item.parent.invoice_id
  # end
  #
  # def invoice_type(invoice_line_item)
  #   # [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice]
  #   case invoice_line_item.parent.invoice_type&.name
  #   when 'tax_invoice'
  #     "PO Invoice"
  #   when 'non_po_invoice'
  #     "NON PO Invoice"
  #   when 'proforma_invoice'
  #     "Proforma Invoice"
  #   else
  #     "Invoice"
  #   end
  # end
  #
  # def invoice_no(invoice_line_item)
  #   invoice_line_item.parent.invoice_number
  # end
  #
  # def vendor_name(invoice_line_item)
  #   invoice_line_item.parent.vendor&.display_name
  # end
  #
  # def vendor_ref_no(invoice_line_item)
  #   invoice_line_item.parent.vendor.vendor_id
  # end
  #
  # def vendor_gstin(invoice_line_item)
  #   invoice_line_item.parent&.gstin_location&.gstin
  # end
  #
  # def vendor_state(invoice_line_item)
  #   invoice_line_item.parent&.gstin_location&.state&.name
  # end
  #
  # # def vendor_gst(invoice_line_item)
  # #   invoice_line_item
  # # end
  #
  # # def po_number(invoice_line_item)
  # #   invoice_line_item
  # # end
  #
  # def transaction_period_from(invoice_line_item)
  #   invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%b-%y")
  # end
  #
  # def transaction_period_to(invoice_line_item)
  #   invoice_line_item.parent.transaction_service_period_to&.strftime("%d-%b-%y")
  # end
  #
  # def invoice_status(invoice_line_item)
  #   invoice_line_item.parent&.status&.name&.titleize
  # end
  #
  # def is_invoice_approved(invoice_line_item)
  #   InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :pending, :initiated).include?(invoice_line_item.parent&.invoice_status_id) ? 'Yes' : 'No'
  # end
  #
  # def category(invoice_line_item)
  #   invoice_line_item.category&.name
  # end
  #
  # def quantity(invoice_line_item)
  #   invoice_line_item.quantity
  # end
  #
  # def rate(invoice_line_item)
  #   invoice_line_item&.rate
  # end
  #
  # def narration(invoice_line_item)
  #   invoice_line_item.parent.narration
  # end
  #
  # def location_name(invoice_line_item)
  #   invoice_line_item.parent.location&.name
  # end
  #
  # def location_code(invoice_line_item)
  #   invoice_line_item.parent.location&.location_code
  # end
  #
  # def department_name(invoice_line_item)
  #   invoice_line_item.department&.name
  # end
  #
  # def department_code(invoice_line_item)
  #   invoice_line_item.department&.department_code
  # end
  #
  # def gst_group(invoice_line_item)
  #   invoice_line_item&.tax_rate&.name
  # end
  #
  # def hsn_sac(invoice_line_item)
  #   invoice_line_item.hsn_sac
  # end
  #
  # # def tds_nature(invoice_line_item)
  # #   invoice_line_item
  # # end
  #
  # def cost_center(invoice_line_item)
  #   invoice_line_item.cost_center&.name
  # end
  #
  # def item_code(invoice_line_item)
  #   invoice_line_item.inventory_line_item&.item_code
  # end
  #
  # def description(invoice_line_item)
  #   invoice_line_item.description
  # end
  #
  # def unit_of_measurement(invoice_line_item)
  #   invoice_line_item.unit_of_measurement
  # end
  #
  # def total_amount(invoice_line_item)
  #   invoice_line_item.amount&.value
  # end
  #
  # def tax_amount(invoice_line_item)
  #   invoice_line_item.tax_amount&.value
  # end
  #
  # def tax_rate(invoice_line_item)
  #   invoice_line_item.tax_rate&.rate
  # end
  #
  # def tax_type(invoice_line_item)
  #   invoice_line_item.tax_rate&.name
  # end
  #
  # def tds_nature(invoice_line_item)
  #   return false unless invoice_line_item&.inventory_line_item&.tds_applicable
  #   invoice_line_item.parent.tds_slab&.name
  # end
  #
  # def tds_amount(invoice_line_item)
  #   return 0.0 unless invoice_line_item&.inventory_line_item&.tds_applicable
  #   invoice_line_item.parent.tds_amount&.value || 0.0
  # end
  #
  # def rcm_enabled(invoice_line_item)
  #   return invoice_line_item.parent.rcm_enabled
  # end
  #
  # def tds_percentage(invoice_line_item)
  #   return 0.0 unless invoice_line_item&.inventory_line_item&.tds_applicable
  #   invoice_line_item.parent.tds_slab&.tds || 0.0
  # end
  #
  # def invoice_discount(invoice_line_item)
  #   invoice_line_item.parent&.discount_amount&.value || 0
  # end
  #
  # def line_item_discount(invoice_line_item)
  #   invoice_line_item.discount_amount&.value || 0
  # end
  #
  # def line_item_sgst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?
  #   invoice_line_item.sgst || 0
  # end
  #
  # def line_item_cgst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?
  #
  #   invoice_line_item.cgst || 0
  # end
  #
  # def line_item_igst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?
  #   invoice_line_item.igst || 0
  # end
  #
  # def advance_amount(invoice_line_item)
  #   if invoice_line_item.parent&.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
  #     value = invoice_line_item.parent&.advance_amount&.value || 0
  #   else
  #     value = invoice_line_item.parent&.procurement&.purchase_order&.advance_amount&.value || 0
  #   end
  #   precision_value(value)
  # end
  #
  # def approvers(invoice_line_item)
  #   approvers = invoice_line_item.parent.dlrms.map do |dlrm|
  #     taken_control_by = forwarded_to = reviewer = nil
  #     taken_control_by = dlrm.taken_control_by
  #     forwarded_to = dlrm.forwarded_to
  #     reviewer = dlrm.reviewer
  #     approved = [TrailAction.id_for(:approve), TrailAction.id_for(:approve_and_forward)].include?(dlrm.action_id)
  #     if forwarded_to.present?
  #       (approved ? "#{forwarded_to.name} - #{dlrm.updated_at.strftime "%I:%M %p, %d-%b-%Y"}" : forwarded_to.name)
  #     elsif taken_control_by.present?
  #       (approved ? "#{taken_control_by.name} - #{dlrm.updated_at.strftime "%I:%M %p, %d-%b-%Y"}" : taken_control_by.name)
  #     elsif reviewer.present?
  #       (approved ? "#{reviewer.name} - #{dlrm.updated_at.strftime "%I:%M %p, %d-%b-%Y"}" : reviewer.name)
  #     end
  #   end
  #   approvers.reject { |e| e.to_s.empty? }.join(", ")
  # end
  #
  # def invoice_net_payable_amount(invoice_line_item)
  #   invoice_line_item.parent&.balance_due&.value || 0
  # end
  #
  # def finance_approved_date(invoice_line_item)
  #   invoice_line_item.parent&.approved_at&.strftime("%d-%b-%Y")
  # end
  #
  # def created_by(invoice_line_item)
  #   invoice_line_item.parent&.created_by&.name
  # end
  #
  # def created_at(invoice_line_item)
  #   invoice_line_item.parent&.created_at&.strftime("%d-%b-%Y")
  # end
  #
  # def po_date(invoice_line_item)
  #   invoice_line_item.purchase_order_item&.purchase_order&.created_at&.strftime("%d-%b-%Y")
  # end
  #
  # def policy(invoice_line_item)
  #   invoice_line_item.parent&.policy&.name
  # end
  #
  # def due_date(invoice_line_item)
  #   invoice_line_item.parent&.due_date&.strftime("%d-%b-%Y")
  # end
  #
  # def attachments(invoice_line_item)
  #   invoice_line_item.parent.attachments.map {|a| a.file.url(:original, timestamp: false)}.compact.join(", ")
  # end
  #
  # def approval_pending_reviewers(invoice_line_item)
  #   invoice_line_item.parent.get_reviewers&.map(&:name)&.join(", ")
  # end

end