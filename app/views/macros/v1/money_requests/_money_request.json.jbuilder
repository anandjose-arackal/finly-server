json.id record.id
json.name record.name
json.approved_at record.approved_at
json.created_at record.created_at
json.submitted_at record.submitted_at
json.purpose record.memo
json.policy record.policy
json.status record.status.name
json.required_by_date record.required_by_date
json.accounted record.accounted
json.submitted_amount record&.submitted_amount&.value || record&.total_amount
json.processed_amount record&.money_request_processor_mapping&.processor&.processed_amount&.value
json.destination_pocket record&.destination_pocket&.name
json.payment_mode record&.payment_mode&.name
json.payment_type record&.money_request_processor_mapping&.processor&.payment_type
json.bank_reference_number record.bank_reference_number
json.source_account record.source_account
json.user do
  json.partial! 'macros/v1/users/user', record: record.user
  json.bank_account record.user.default_bank_account
end
custom_fields = {}
record.custom_fields.each do |custom_field|
  custom_fields[custom_field.field_configuration.field_name] = custom_field&.configured_field_value
end
json.custom_fields custom_fields
json.total_amount do
  json.partial! 'shared/amount', amount: Amount.new(value: record&.total_amount, currency_id: record.policy&.base_currency_id)
end
json.approval_workflow record.dlrms do |dlrm|
  json.partial! 'macros/v1/shared/approval_workflow', dlrm: dlrm
end
json.request_items record.items do |item|
  json.category do
    json.name item.category&.name
    json.id item.category&.id
  end
  json.amount do
    json.value item.amount.value
    json.currency do
      json.id item.amount.currency.id
    end
  end
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
