models = @op['model.index']

json.result do
  json.array! models do |model|
    json.extract! model, :id, :created_at, :updated_at
    json.controling_entity model.controlling_entity.label
    json.dependent_entity model.dependent_entity.label
    json.created_by model.created_by.name
    json.updated_by model.updated_by.name

  end
end
