# These fields are a replica of Invoice Exports
json.result do
  json.array!(@result.paginated_invoice_line_items) do |invoice_line_item|
    invoice = invoice_line_item.parent
    # standard fields
    json.extract! invoice_line_item, :id, :parent_id

    json.order_number (invoice.po_number || invoice.invoice_id)

    json.invoice_date invoice.date&.strftime("%Y-%m-%d %H:%M:%S")
    json.delivery_location invoice.delivery_location&.name
    json.vendor_id invoice.vendor_id
    json.total_tax invoice_line_item.tax_amount&.value
    json.invoice_id invoice.invoice_id
    json.invoice_type invoice.invoice_type&.name&.titleize
    json.invoice_number invoice.invoice_number
    json.vendor_name invoice.vendor&.display_name
    json.vendor_ref_no invoice.vendor&.vendor_id
    json.vendor_gstin invoice.gstin_location&.gstin
    json.transaction_period_from invoice.transaction_service_period_from&.strftime("%Y-%m-%d %H:%M:%S")
    json.transaction_period_to invoice.transaction_service_period_to&.strftime("%Y-%m-%d %H:%M:%S")
    json.invoice_status invoice.status&.name&.humanize
    json.category invoice_line_item.category&.name
    json.quantity invoice_line_item.quantity
    json.rate invoice_line_item&.rate
    json.narration invoice.narration
    json.city_name invoice.location&.name
    json.city_code invoice.location&.location_code
    json.department_name invoice_line_item.department&.name
    json.department_code invoice_line_item.department&.department_code
    json.gst_group invoice_line_item&.tax_rate&.name
    json.hsn_sac invoice_line_item.hsn_sac
    json.cost_center invoice_line_item.cost_center&.name
    json.cost_center_code invoice_line_item.cost_center&.cost_center_code
    json.item_code invoice_line_item.inventory_line_item&.item_code
    json.description invoice_line_item.description
    json.unit_of_measurement invoice_line_item.unit_of_measurement
    json.total_amount invoice_line_item.amount&.value
    json.tax_amount invoice_line_item.tax_amount&.value
    json.tax_rate invoice_line_item.tax_rate&.rate
    json.tax_type invoice_line_item.tax_rate&.name
    json.tax_internal_id invoice_line_item.tax_rate&.internal_id
    json.tds_nature invoice.tds_slab&.name
    json.tds_amount invoice.tds_amount&.value || 0.0
    json.tds_percentage invoice.tds_slab&.tds || 0.0
    json.invoice_discount invoice.discount_amount&.value || 0
    json.line_item_discount invoice_line_item.discount_amount&.value || 0
    json.line_item_sgst invoice_line_item.sgst || 0
    json.line_item_cgst invoice_line_item.cgst || 0
    json.line_item_igst invoice_line_item.igst || 0

    json.line_item_sgst_percentage (invoice_line_item.tax.to_f/2) || 0
    json.line_item_cgst_percentage (invoice_line_item.tax.to_f/2) || 0
    json.line_item_igst_percentage invoice_line_item.tax || 0

    if invoice.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
      value = invoice.advance_amount&.value || 0
    else
      value = invoice.procurement&.purchase_order&.advance_amount&.value || 0
    end

    json.advance_amount value.round(2)

    json.invoice_net_payable_amount invoice.balance_due&.value || 0
    json.finance_approved_date invoice.approved_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.created_by invoice.created_by&.name
    json.created_at invoice.created_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.po_date invoice_line_item.purchase_order_item&.purchase_order&.created_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.gl_code invoice_line_item.inventory_line_item&.category&.gl_code rescue nil
    json.gst_type invoice.gst_type&.name&.titleize rescue nil
    json.line_item_type invoice_line_item&.inventory_line_item&.supply_item_type&.name&.humanize
    json.line_item_expense_type invoice_line_item&.inventory_line_item&.item_expense_type&.name&.humanize
    json.nature_of_item invoice_line_item&.inventory_line_item&.product_type&.name&.humanize

    # extra fields
    json.buyer_location_state invoice.location&.state&.name
    json.buyer_location_code invoice.location&.location_code

    json.delivery_location_state invoice.delivery_location&.state&.name
    json.delivery_location_code invoice.delivery_location&.location_code

    json.gstin_location_state invoice.gstin_location&.state&.name
    json.gstin_location_city invoice.gstin_location&.location
    json.gstin_location_code invoice.gstin_location&.state&.state_code

    json.poc_email invoice.vendor_location&.poc_email
    json.poc_mobile_number invoice.vendor_location&.poc_mobile_number

    json.beneficiary_ifsc invoice.bank_account&.ifsc
    json.beneficiary_account_number invoice.bank_account&.account_number
    json.beneficiary_account_name invoice.bank_account&.name

    json.invoice_creator_name "#{invoice.created_by&.first_name} #{invoice.created_by&.last_name}"
    json.invoice_creator_employee_id invoice.created_by&.employee_id
    json.invoice_creator_email invoice.created_by&.email
  end
end
json.count @result.invoice_line_items.count