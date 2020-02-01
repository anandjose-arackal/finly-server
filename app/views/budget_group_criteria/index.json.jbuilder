json.result do
  budget_group = @op["model"]
  json.budget_group budget_group
  json.budget_group_criteria @op["budget_group_criteria"]
end

json.count @op["budget_group_criteria"].count