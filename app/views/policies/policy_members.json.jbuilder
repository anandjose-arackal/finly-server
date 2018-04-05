json.users do
  json.array!(@result.policy_users) do |policy_user|
    json.name policy_user.name
    json.mobile_number policy_user.mobile_number
    json.manager policy_user.team_mapping.policy(@result.policy).manager.first&.user&.email
    json.finance_manager policy_user.team_mapping.policy(@result.policy).finance_manager.first&.user&.email
    json.approves_to policy_user.team_mapping.policy(@result.policy).approves_to.first&.user&.email
    json.approves_finance_to policy_user.team_mapping.policy(@result.policy).approves_finance_to.first&.user&.email
  end
end