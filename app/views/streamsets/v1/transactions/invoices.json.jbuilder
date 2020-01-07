# These fields are a replica of Invoice Exports
json.result do
  json.array!(@result.paginated_invoice_line_items) do |invoice_line_item|
    # standard fields
    json.extract! invoice_line_item, :id, :parent_id

    json.order_number (invoice_line_item.parent.po_number || invoice_line_item.parent.invoice_id)
    
    json.invoice_date invoice_line_item.parent&.date&.strftime("%d-%b-%y")
    json.delivery_location invoice_line_item.parent&.delivery_location&.name
    json.vendor_id invoice_line_item.parent&.vendor_id
    json.total_tax invoice_line_item.tax_amount&.value
    json.invoice_id invoice_line_item.parent.invoice_id
    json.invoice_type invoice_line_item.parent.invoice_type&.name&.titleize
    json.invoice_number invoice_line_item.parent.invoice_number
    json.vendor_name invoice_line_item.parent.vendor&.display_name
    json.vendor_ref_no invoice_line_item.parent.vendor&.vendor_id
    json.vendor_gstin invoice_line_item.parent&.gstin_location&.gstin
    json.transaction_period_from invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%b-%y")
    json.transaction_period_to invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%b-%y")
    json.invoice_status invoice_line_item.parent&.status&.name&.humanize
    json.category invoice_line_item.category&.name
    json.quantity invoice_line_item.quantity
    json.rate invoice_line_item&.rate
    json.narration invoice_line_item.parent.narration
    json.city_name invoice_line_item.parent.location&.name
    json.city_code invoice_line_item.parent.location&.location_code
    json.department_name invoice_line_item.department&.name
    json.department_code invoice_line_item.department&.department_code
    json.gst_group invoice_line_item&.tax_rate&.name
    json.hsn_sac invoice_line_item.hsn_sac
    json.cost_center invoice_line_item.cost_center&.name
    json.item_code invoice_line_item.inventory_line_item&.item_code
    json.description invoice_line_item.description
    json.unit_of_measurement invoice_line_item.unit_of_measurement
    json.total_amount invoice_line_item.amount&.value
    json.tax_amount invoice_line_item.tax_amount&.value
    json.tax_rate invoice_line_item.tax_rate&.rate
    json.tax_type invoice_line_item.tax_rate&.name
    json.tds_nature invoice_line_item.parent.tds_slab&.name
    json.tds_amount invoice_line_item.parent.tds_amount&.value || 0.0
    json.tds_percentage invoice_line_item.parent.tds_slab&.tds || 0.0
    json.invoice_disscount invoice_line_item.parent&.discount_amount&.value || 0
    json.line_item_discount invoice_line_item.discount_amount&.value || 0
    json.line_item_sgst invoice_line_item.sgst || 0
    json.line_item_cgst invoice_line_item.cgst || 0
    json.line_item_igst invoice_line_item.igst || 0

    if invoice_line_item.parent&.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
      value = invoice_line_item.parent&.advance_amount&.value || 0
    else
      value = invoice_line_item.parent&.procurement&.purchase_order&.advance_amount&.value || 0
    end

    json.advance_amount value.round(2)

    json.invoice_net_payable_amount invoice_line_item.parent&.balance_due&.value || 0
    json.finance_approved_date invoice_line_item.parent&.approved_at&.strftime("%d-%b-%Y")
    json.created_by invoice_line_item.parent&.created_by&.name
    json.created_at invoice_line_item.parent&.created_at&.strftime("%d-%b-%Y")
    json.po_date invoice_line_item.purchase_order_item&.purchase_order&.created_at&.strftime("%d-%b-%Y")

    # extra fields
    json.buyer_location_state invoice_line_item.parent.location&.state&.name
    json.buyer_location_code invoice_line_item.parent.location&.state&.code

    json.delivery_location_state invoice_line_item.parent.delivery_location&.state&.name
    json.delivery_location_code invoice_line_item.parent.delivery_location&.state&.code

    json.gstin_location_state invoice_line_item.parent.gstin_location&.state&.name
    json.gstin_location_code invoice_line_item.parent.gstin_location&.state&.state_code
  end
end
json.count @result.invoice_line_items.count