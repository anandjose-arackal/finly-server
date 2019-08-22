json.company_departments @result.department_mapping
# json.company_departments @result.policy.company.departments.arrange_serializable(order: :name)
json.policy_department_mapping @result.policy&.policy_department_mappings&.pluck(:department_id)