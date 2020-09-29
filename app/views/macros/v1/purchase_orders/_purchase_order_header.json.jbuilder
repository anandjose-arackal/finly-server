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
json.approved_at record.approved_at
json.due_date record.due_date
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