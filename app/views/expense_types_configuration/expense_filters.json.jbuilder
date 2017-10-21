json.groups do
  json.array! @groups do |group|
    json.id group.id
    json.name group.name
    json.items do
      json.array! group.user_group_items, :id, :name
    end
  end
end
json.teams do
  json.array! @teams, :id, :name
end
json.custom_fields do
  json.array! @field_configurations, :field_name, :id, :field_type
end