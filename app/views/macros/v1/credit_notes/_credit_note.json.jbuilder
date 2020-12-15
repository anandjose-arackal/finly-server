json.partial! 'credit_note_header', record: record
json.approval_workflow record.dlrms do |dlrm|
  json.partial! 'macros/v1/shared/approval_workflow', dlrm: dlrm
end
json.line_items do
  json.array! record.items do |item|
    item.as_json
  end
end

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
