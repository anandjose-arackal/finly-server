json.extract! record, :id, :name, :user, :active

json.applicable_entities do
  json.purchase_order record.purchase_order
  json.payment record.payment
  json.expense record.expense
  json.invoice record.invoice
  json.purchase_request record.purchase_request
end

json.start_date record.start_date&.strftime("%d-%b-%Y")
json.end_date record.end_date&.strftime("%d-%b-%Y")

budget_consumption = record.budget_consumption
json.budget_consumption budget_consumption

json.budget_group_details record.budget_group

json.budget_details record.as_json

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at