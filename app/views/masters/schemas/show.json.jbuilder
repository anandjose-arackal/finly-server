model = @op["model"]
records = @op["model.records"]
json.data do
  json.name model.name
  json.master_key model.master_key
  json.schema model.entities
  json.records records
end
