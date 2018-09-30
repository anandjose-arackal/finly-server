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

  end

  def custom_field_value_for(field_configuration)

  end

end