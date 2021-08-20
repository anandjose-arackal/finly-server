json.id record.id
json.approved_at record.approved_at
json.created_at record.created_at
json.note record.memo
json.bank_reference_number record.bank_reference_number
json.source_account record.source_account
json.submitted_at record.submitted_at
json.policy record.policy
json.payment_type record.report_processor_group_mapping&.processor_group&.payment_type
json.user do
  json.partial! 'macros/v1/users/user', record: record.user
  json.bank_account record.user.default_bank_account
end
record.custom_fields.each do |custom_field|
  custom_fields[custom_field.field_configuration.field_name] = custom_field.configured_field_value
end
json.custom_fields custom_fields
json.expenses record.expenses do |expense|
  json.partial! 'expense', record: expense
end
json.total_amount do
  json.partial! 'shared/amount', amount: Amount.new(value: record&.total_amount, currency_id: record.policy&.base_currency_id)
end
json.approval_workflow record.dlrms do |dlrm|
  json.partial! 'macros/v1/shared/approval_workflow', dlrm: dlrm
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at