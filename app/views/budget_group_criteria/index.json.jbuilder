json.result do
  json.array! @result["budget_group_criteria"]
end

json.count @result["budget_group_criteria"]