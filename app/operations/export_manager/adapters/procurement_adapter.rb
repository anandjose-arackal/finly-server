class ExportManager::Adapters::ProcurementAdapter < ExportManager::Adapters::BaseAdapter

  handle :procurement
  fields [
             vendor_name: {spreadsheet: true, pdf: true},
             vendor_business_name: {spreadsheet: true, pdf: true},
             vendor_mobile_number: {spreadsheet: true, pdf: true},
             vendor_state_code: {spreadsheet: true, pdf: true},
             vendor_pan: {spreadsheet: true, pdf: true},
             vendor_tds_rate: {spreadsheet: true, pdf: true},
             vendor_tds_description: {spreadsheet: true, pdf: true},
             vendor_type: {spreadsheet: true, pdf: true},
             vendor_description: {spreadsheet: true, pdf: true},
             vendor_address: {spreadsheet: true, pdf: true},
             vendor_custom_fields: {spreadsheet: true, pdf: true},
             policy: {spreadsheet: true, pdf: true},
             department: {spreadsheet: true, pdf: true},
             sub_department: {spreadsheet: true, pdf: true},
             cost_center: {spreadsheet: true, pdf: true},
             po_number: {spreadsheet: true, pdf: true},
             po_payment_term: {spreadsheet: true, pdf: true},
             po_delivery_date: {spreadsheet: true, pdf: true},
             po_submitted_on: {spreadsheet: true, pdf: true},
             po_approved_on: {spreadsheet: true, pdf: true},
             po_sent_on: {spreadsheet: true, pdf: true},
             po_base_value: {spreadsheet: true, pdf: true},
             po_cgst: {spreadsheet: true, pdf: true},
             po_sgst: {spreadsheet: true, pdf: true},
             po_igst: {spreadsheet: true, pdf: true},
             po_line_items_count: {spreadsheet: true, pdf: true},
             po_purchase_address: {spreadsheet: true, pdf: true},
             po_delivery_address: {spreadsheet: true, pdf: true},
             po_custom_fields: {spreadsheet: true, pdf: true},
             inwards_status: {spreadsheet: true, pdf: true},
             last_inward_received_on: {spreadsheet: true, pdf: true},
             invoice_number: {spreadsheet: true, pdf: true},
             invoice_payment_term: {spreadsheet: true, pdf: true},
             invoice_delivery_date: {spreadsheet: true, pdf: true},
             invoice_submitted_on: {spreadsheet: true, pdf: true},
             invoice_approved_on: {spreadsheet: true, pdf: true},
             invoice_sent_on: {spreadsheet: true, pdf: true},
             invoice_base_value: {spreadsheet: true, pdf: true},
             invoice_cgst: {spreadsheet: true, pdf: true},
             invoice_sgst: {spreadsheet: true, pdf: true},
             invoice_igst: {spreadsheet: true, pdf: true},
             invoice_tds_type: {spreadsheet: true, pdf: true},
             invoice_tds_amount: {spreadsheet: true, pdf: true},
             invoice_total_amount_after_tds: {spreadsheet: true, pdf: true},
             invoice_payable_amount: {spreadsheet: true, pdf: true},
             invoice_line_items_count: {spreadsheet: true, pdf: true},
             invoice_purchase_address: {spreadsheet: true, pdf: true},
             invoice_delivery_address: {spreadsheet: true, pdf: true},
             invoice_custom_fields: {spreadsheet: true, pdf: true}
         ]

  def init_list
    Procurement.limit(10)
  end

  def vendor_name(entry)

  end

  def vendor_business_name(entry)

  end

  def vendor_mobile_number(entry)

  end

  def vendor_state_code(entry)

  end

  def vendor_pan(entry)

  end

  def vendor_tds_rate(entry)

  end

  def vendor_tds_description(entry)

  end

  def vendor_type(entry)

  end

  def vendor_description(entry)

  end

  def vendor_address(entry)

  end

  def vendor_custom_fields(entry)

  end

  def policy(entry)

  end

  def department(entry)

  end

  def sub_department(entry)

  end

  def cost_center(entry)

  end

  def po_number(entry)

  end

  def po_payment_term(entry)

  end

  def po_delivery_date(entry)

  end

  def po_submitted_on(entry)

  end

  def po_approved_on(entry)

  end

  def po_sent_on(entry)

  end

  def po_base_value(entry)

  end

  def po_cgst(entry)

  end

  def po_sgst(entry)

  end

  def po_igst(entry)

  end

  def po_line_items_count(entry)

  end

  def po_purchase_address(entry)

  end

  def po_delivery_address(entry)

  end

  def po_custom_fields(entry)

  end

  def inwards_status(entry)

  end

  def last_inward_received_on(entry)

  end

  def invoice_number(entry)

  end

  def invoice_payment_term(entry)

  end

  def invoice_delivery_date(entry)

  end

  def invoice_submitted_on(entry)

  end

  def invoice_approved_on(entry)

  end

  def invoice_sent_on(entry)

  end

  def invoice_base_value(entry)

  end

  def invoice_cgst(entry)

  end

  def invoice_sgst(entry)

  end

  def invoice_igst(entry)

  end

  def invoice_tds_type(entry)

  end

  def invoice_tds_amount(entry)

  end

  def invoice_total_amount_after_tds(entry)

  end

  def invoice_payable_amount(entry)

  end

  def invoice_line_items_count(entry)

  end

  def invoice_purchase_address(entry)

  end

  def invoice_delivery_address(entry)

  end

  def invoice_custom_fields(entry)

  end


end