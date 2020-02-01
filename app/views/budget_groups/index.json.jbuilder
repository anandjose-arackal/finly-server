json.result do
  json.array! @op["budget_groups"]
end
json.count @op["budget_groups"].count