exposure = record.to_exposure
json.id record.id
json.invoice_id record.invoice_id
json.invoice_number record.invoice_number
json.narration record.narration
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
    json.tax_id record.vendor.pan
  end
  # else
  # json.vendor nil
end
json.vendor_location record.gstin_location
json.billing_location record.location
json.shipping_location record.delivery_location
json.beneficiary_account record.bank_account