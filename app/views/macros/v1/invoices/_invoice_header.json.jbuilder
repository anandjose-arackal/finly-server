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
json.invoice_type record&.invoice_type&.name
json.submitted_at record.submitted_at
json.approved_at record.approved_at
json.transaction_service_period_from record.transaction_service_period_from
json.transaction_service_period_to record.transaction_service_period_to
json.invoice_date record.date
json.due_date record.due_date
json.po_number exposure.po_number
json.reporting_currency record.get_reporting_currency.country_code
json.base_currency record.get_base_currency.country_code
json.exchange_rate record.exchange_rate
json.discount_amount exposure.discount_amount_value
json.tax_type exposure.tax_type_name
json.tax_amount exposure.tax_amount&.value
json.tds_slab record.tds_slab
json.tds_rate record.tds_slab&.tds
json.tds_amount exposure.tds_amount_value
json.display_tds_amount record.display_tds_amount
json.freight_amount exposure.freight_amount_value
json.net_amount exposure.net_amount_value
json.paid_amount exposure.paid_amount_value
json.balance_payable exposure.balance_payable_value
json.roundoff_amount exposure.roundoff_amount
json.payment_term exposure.payment_term&.name
# json.cost_allocation exposure.cost_allocation
json.header_level_cost_center record&.cost_center
json.header_level_department record&.department
json.policy record.policy
if record.vendor.present?
  json.vendor do
    json.id record.vendor.id
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
json.beneficiary_account_form_custom_fields do 
  json.array! record.bank_account.form_custom_fields.each do |form_custom_field|
    json.name form_custom_field.form_entity&.label
    json.field_key form_custom_field.field_key
    json.field_value form_custom_field.retrieve_text_value
  end 
end
json.po_advance_adjusted record.advance_amount_required
json.rcm_applicable record.rcm_enabled
if record.advance_amount_required
  json.po_adjusted_advance_amount exposure.po_adjusted_advance_value
  json.po_advance record.po_advance
  json.po_prev_adjusted_advance record.po_prev_adjusted_advance
  json.po_advance_paid_at record.procurement&.purchase_order&.payments&.last&.date&.strftime("%d-%b-%y")
end