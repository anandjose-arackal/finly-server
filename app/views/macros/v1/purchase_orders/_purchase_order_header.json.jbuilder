json.id record.id
json.po_number record.po_number

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
json.updated_at record.updated_at
json.created_at record.created_at
json.approved_at record.approved_at
json.due_date record.due_date
json.policy record.policy
json.gross_amount record&.total_before_tax&.value.to_f + record&.discount_amount&.value.to_f
json.tax_amount record&.tax_amount&.value
json.net_amount record&.total_after_tax&.value
json.round_off record&.roundoff_amount
json.po_balance_payable (record&.forms_enabled ? record&.po_balance_due : record&.balance_amount&.value)

po_gross_amount = record&.forms_enabled ? record&.po_requested_advance_amount : ((record&.advance_amount&.value + record&.advance_tds_amount&.value) rescue 0)

if record&.advance_amount_required
  json&.advance_details do
    if record&.forms_enabled
        json.gross_po_advance_amount po_gross_amount
        json.net_po_advance_amount record&.po_advance_amount
        json.po_advance_tds_percentage record&.advance_tds_slab&.tds
        json.po_advance_tds_amount (po_gross_amount * ((record&.advance_tds_slab&.tds&.to_f/100) rescue 0))
    else
      json.gross_po_advance_amount record&.advance_amount&.value
      json.net_po_advance_amount (record&.advance_amount&.value - (record&.advance_amount&.value * ((record&.advance_tds_slab&.tds&.to_f/100) rescue 0)))
      json.po_advance_tds_percentage record&.advance_tds_slab&.tds
      json.po_advance_tds_amount (record&.advance_amount&.value * ((record&.advance_tds_slab&.tds&.to_f/100) rescue 0))
    end
  end
end

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
json.beneficiary_account_form_custom_fields do 
  json.array! record.bank_account.form_custom_fields.each do |form_custom_field|
    json.name form_custom_field.form_entity&.label
    json.field_key form_custom_field.field_key
    json.field_value form_custom_field.retrieve_text_value
  end 
end