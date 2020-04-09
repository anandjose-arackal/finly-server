json.result do
  budget_group = @op["model"]
  json.budget_group budget_group.as_json
  if budget_group.budgets.present?
    json.budgets budget_group.budgets.as_json
  end
end