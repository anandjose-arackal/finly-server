json.company_locations @result.policy.company.locations.arrange_serializable(order: :name)
json.policy_location_mapping @result.policy.locations.pluck(:id)