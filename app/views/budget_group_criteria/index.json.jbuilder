json.result do
  budget_group = @op["model"]
  # budget_group_criteria = @op["budget_group_criteria"]
  json.budget_group budget_group
  json.budget_group_criteria @op["budget_group_criteria"]
end

json.count @op["budget_group_criteria"].count