json.data @op["model.records"].each do |record|
  json.key record.master_key
  json.name record.name
end
