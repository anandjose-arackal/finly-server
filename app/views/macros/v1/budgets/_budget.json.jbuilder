json.id record.id
json.name record.name
json.active record.active
json.start_date record.start_date&.strftime("%d-%m-%Y")
json.end_date record.end_date&.strftime("%d-%m-%Y")
json.budget_amount record.budget_consumption.budget_amount.as_json
json.spent_amount record.budget_consumption.total_consumed_amount.as_json
json.budget_consumption record.budget_consumption
json.budget_group record.budget_group
json.calculated_before_tax_amount record.calculated_before_tax_amount
json.criteria_id record.budget_group_criterium&.id
json.criteria_name record.budget_group_criterium&.name
json.associated_vendors record.budget_group_criterium&.budgetable_vendors&.collect {|vendor| {id:vendor.id, name: (vendor.name ||  vendor.business_name) }}
json.associated_categories record.budget_group_criterium&.budgetable_categories.as_json
json.associated_cost_centers record.budget_group_criterium&.budgetable_cost_centers.as_json
json.associated_locations record.budget_group_criterium&.budgetable_locations.as_json
json.associated_departments record.budget_group_criterium&.budgetable_departments.as_json
json.associated_users record.budget_group_criterium&.budgetable_users&.collect {|vendor| {id:vendor.id, name:vendor.name}}

json.user do
  json.id record.user.id
  json.mobile_number record.user.mobile_number
  json.email record.user.email
end

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at