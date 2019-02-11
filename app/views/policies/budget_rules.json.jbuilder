json.warning_rules do
  json.array!(@result.policy.budget_rules.warning_rules.non_deleted) do |rule|
    json.id rule.id
    json.rule_in_words rule.rule_in_words
  end
end

json.blocking_rules do
  json.array!(@result.policy.budget_rules.blocking_rules.non_deleted) do |rule|
    json.id rule.id
    json.rule_in_words rule.rule_in_words
  end
end

json.policy_admin current_user.policy_admin?(@result.policy)

json.policy_custom_fields @result.policy_custom_fields