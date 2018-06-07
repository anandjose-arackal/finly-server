json.groups do
  json.array! @groups do |group|
    json.id group.id
    json.name group.name
    json.items do
      json.array! group.user_group_items, :id, :name
    end
  end
end
json.policies do
  json.array! @policies.policies, :id, :name
end
json.teams do
  json.array! @teams, :id, :name
end
json.custom_fields do
  json.array! @field_configurations, :field_name, :id, :field_type, :drop_down_items
end

json.categories do
  json.array! @categories, :id, :name
end