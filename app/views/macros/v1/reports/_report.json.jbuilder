json.id record.id
json.approved_at record.approved_at
json.created_at record.created_at
json.note record.memo
json.bank_reference_number record.bank_reference_number
json.source_account record.source_account
json.submitted_at record.submitted_at
json.policy record.policy
json.user do
  json.partial! 'macros/v1/users/user', record: record.user
  json.bank_account record.user.default_bank_account
end
json.expenses record.expenses do |expense|
  json.partial! 'expense', record: expense
end

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at