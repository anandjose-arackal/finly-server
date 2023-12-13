json.id record.id
json.vendor_id record.vendor_id
json.business_name record.business_name
json.trade_name record.trade_name
json.gst_registered !!record.gst_registered
json.vendor_type record.vendor_type&.as_json
json.status record.status.name
json.payment_term record.payment_term
json.policy record.policy
json.rcm_enabled record.rcm_enabled
json.pan_number record.pan
json.msme_registered record.msme_registered
json.msme_registration_number record.msme_registration_number
json.tds_rates record.tds_rates
json.locations do
  json.array! record.gstin_locations.each do |gstin_location|
    json.merge! gstin_location.as_json
    json.location_custom_fields do
      json.array! gstin_location.form_custom_fields.each do |location_custom_field|
        json.name location_custom_field.form_entity&.label
        json.field_key location_custom_field.field_key
        json.field_value location_custom_field.retrieve_text_value
      end
    end
  end
end
json.bank_accounts record.bank_accounts
json.created_at record.created_at
json.updated_at record.updated_at
json.submitted_at record.submitted_at
json.approved_at record.approved_at
json.created_by record.created_by
json.vendor_country record.vendor_country
json.address record.address
json.tax_rate record.tax_rate
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

json.form_custom_fields do
  json.array! record.form_custom_fields.each do |form_custom_field|
    json.name form_custom_field.form_entity&.label
    json.field_key form_custom_field.field_key
    json.field_value form_custom_field.retrieve_text_value
  end
end
json.approval_workflow record.dlrms do |dlrm|
  json.partial! 'macros/v1/shared/approval_workflow', dlrm: dlrm
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
