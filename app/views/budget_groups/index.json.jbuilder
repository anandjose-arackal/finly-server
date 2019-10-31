json.result do
  json.array! @result["budget_groups"]
end
json.count @result["budget_groups"].count