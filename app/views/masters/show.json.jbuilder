model = @op["model"]
records = @op["model.records"]
json.data do
  json.name model.name
  json.master_key model.master_key
  json.schema model.entities
  json.records records do |record|
    json.id record.id
    model.entities.each do |entity|
      json.set! entity.entity_key, record.send(entity.entity_key)
    end
  end
end