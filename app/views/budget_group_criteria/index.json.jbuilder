json.result do
  budget_group = @result["model"]
  json.budget_group budget_group
  json.budget_group_criteria @result["budget_group_criteria"]
end

json.count @result["budget_group_criteria"].count