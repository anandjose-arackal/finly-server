json.results do
  json.array! @op['model.records'].each do |record|
    json.id record.id
    json.name record.name
    json.description record.description
    json.export_format record.export_format
    json.resource record.resource
    json.template record.template
    json.query record.query
    json.active record.active
    json.personal record.personal
    json.created_by record.created_by&.name
    json.created_at record.created_at
    json.updated_at record.updated_at
    json.user_roles do
      json.array! record.user_roles
    end
    json.system_template record.system_template?
  end
end
json.count @op['model.records'].count
