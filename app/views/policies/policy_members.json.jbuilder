json.users do
  json.array!(@result.policy_users) do |policy_user|
    json.id policy_user.id
    json.name policy_user.name
    json.mobile_number policy_user.mobile_number
    json.email policy_user.email
    json.manager policy_user.team_mapping.policy(@result.policy).with_purpose(Purpose.id_from_application_for(RequestStoreUtil.current_app)).manager.first&.manager&.email
    json.finance_manager policy_user.team_mapping.policy(@result.policy).with_purpose(Purpose.id_from_application_for(RequestStoreUtil.current_app)).finance_manager.first&.finance_manager&.email
    json.approves_to policy_user.team_mapping.policy(@result.policy).with_purpose(Purpose.id_from_application_for(RequestStoreUtil.current_app)).approves_to.first&.approves_to&.email
    json.approves_finance_to policy_user.team_mapping.policy(@result.policy).with_purpose(Purpose.id_from_application_for(RequestStoreUtil.current_app)).approves_finance_to.first&.approves_finance_to&.email
  end
end