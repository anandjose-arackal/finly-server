json.id record.id
json.vendor_id record.vendor_id
json.business_name record.business_name
json.trade_name record.trade_name
json.gst_registered !!record.gst_registered
json.vendor_type record.vendor_type&.as_json
json.payment_term record.payment_term
json.policy record.policy
json.rcm_enabled record.rcm_enabled
json.pan_number record.pan
json.msme_registered record.msme_registered
json.msme_registration_number record.msme_registration_number
json.tds_rates record.tds_rates
json.locations record.gstin_locations
json.bank_accounts record.bank_accounts
type_map = {}
record.vendor_attachments.each do |attachment|
  type_map[attachment.attachment_type] ||= []
  type_map[attachment.attachment_type] << attachment.as_json
end
json.attachments type_map
json.custom_fields do
  record.custom_fields.each do |custom_field|
    json.set! custom_field.field_configuration&.field_name, custom_field.configured_field_value
  end
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
