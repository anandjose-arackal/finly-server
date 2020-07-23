exposure = record.to_exposure
json.id record.id
json.invoice_id record.invoice_id
json.invoice_number record.invoice_number
json.created_by do
  json.first_name record.created_by&.first_name
  json.last_name record.created_by&.last_name
  json.name record.created_by&.name
  json.email record.created_by&.email
  json.mobile_number record.created_by&.mobile_number
  json.employee_id record.created_by&.profile&.employee_id
end
json.status record.status
json.submitted_at record.submitted_at
json.approved_at record.approved_at
json.transaction_service_period_from record.transaction_service_period_from
json.transaction_service_period_to record.transaction_service_period_to
json.invoice_date record.date
json.due_date record.due_date
json.po_number exposure.po_number
json.discount_amount exposure.discount_amount_value
json.tax_type exposure.tax_type_name
json.tax_amount exposure.tax_amount&.value
json.tds_slab record.tds_slab
json.tds_rate record.tds_rate
json.tds_amount exposure.tds_amount_value
json.freight_amount exposure.freight_amount_value
json.net_amount exposure.net_amount_value
json.paid_amount exposure.paid_amount_value
json.balance_payable exposure.balance_payable_value
# json.cost_allocation exposure.cost_allocation
# json.cost_center record.cost_center
# json.department record.department
json.policy record.policy
if record.vendor.present?
  json.vendor do
    json.vendor_id record.vendor.vendor_id
    json.business_name record.vendor.business_name
    json.trade_name record.vendor.trade_name
  end
  # else
  # json.vendor nil
end
json.vendor_location record.gstin_location
json.billing_location record.location
json.shipping_location record.delivery_location
json.beneficiary_account record.bank_account
json.line_items do
  json.array! record.items do |item|
    json.id item.id
    json.item_type item.inventory_line_item&.supply_item_type&.name
    json.item_expense_type item.inventory_line_item&.item_expense_type&.name
    json.product_type item.inventory_line_item&.product_type&.name
    json.item_code item.inventory_line_item&.item_number
    json.description item.description
    json.category item.category
    json.department item.department
    json.cost_center item.cost_center
    json.hsn_sac item.hsn_sac
    json.tds_applicable item.tds_applicable
    json.unit_of_measurement item.unit_of_measurement
    json.quantity item.quantity
    json.rate item.rate
    json.gross_amount item.amount&.value
    json.discount item.discount
    json.discount_amount item.discount_amount&.value
    json.taxable_amount item.taxable_amount&.value
    json.tax_rate item.tax_rate
    json.tax_amount item.tax_amount&.value
    json.net_amount item.net_amount&.value
  end
end
json.attachments do
  json.array! record.attachments.reject { |attachment| attachment.file_file_size.nil? } do |attachment|
    json.extract! attachment, :description
    json.file_name attachment.file_file_name
    json.file_size attachment.file_file_size
    json.url attachment.file.url(:original, timestamp: false)
    json.content_type attachment&.file_content_type
  end
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
