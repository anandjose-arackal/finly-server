json.data @op["model.records"].each do |record|
  json.key record.table_name
  json.name record.name
end