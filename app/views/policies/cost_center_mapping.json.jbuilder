# json.cost_center_mapping @result.cost_center_mapping.as_json
json.company_cost_centers @result.cost_centers.as_json

json.policy_cost_center_mapping @result.policy.policy_cost_center_mappings.pluck(:cost_center_id)