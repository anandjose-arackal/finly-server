json.result do
  json.id @op['model'].id
  json.name @op['model'].name
  json.description @op['model'].description
  json.export_format @op['model'].export_format
  json.resource @op['model'].resource
  json.template @op['model'].template
  json.query @op['model'].query
  json.active @op['model'].active
  json.personal @op['model'].personal
  json.created_by @op['model'].created_by&.name
  json.created_at @op['model'].created_at
  json.updated_at @op['model'].updated_at
  json.user_roles do
    json.array! @op['model'].user_roles
  end
end
