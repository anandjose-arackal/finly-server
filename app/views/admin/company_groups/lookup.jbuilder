json.data @op["model.records"].each do |company_group|
  json.id company_group.id
  json.name company_group.name
end