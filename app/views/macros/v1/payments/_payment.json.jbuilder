exposure = record.to_exposure
json.id record.id
json.amount record.amount&.value
json.date exposure.date
json.reference_id exposure.reference_id
json.initiating_user_type record.initiating_user_type
json.receiving_user_type record.receiving_user_type
json.receiving_user record.receiving_user
json.receiving_account_type record.receiving_account_type
# json.receiving_account record.receiving_account
json.status record.status
json.payment_mode record.payment_mode
json.utr record.utr
json.created_at record.created_at
json.updated_at record.updated_at
json.submitted_at record.payment_order.bank_payment_request.submitted_at
json.approved_at record.payment_order.bank_payment_request.approved_at
json.processed_at record.processed_at
json.last_retried_at record.last_retried_at
json.note exposure.note
json.parent_type record.parent_type


json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at
