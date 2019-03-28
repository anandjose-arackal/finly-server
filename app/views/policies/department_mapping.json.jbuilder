json.company_departments @result.policy.company.departments.arrange_serializable(order: :name)
json.policy_department_mapping @result.policy.departments.arrange_serializable(order: :name)