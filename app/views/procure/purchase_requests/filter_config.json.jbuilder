json.locations @result.locations.as_json(tree: true)
json.departments @result.departments.as_json(tree: true)
json.cost_centers @result.cost_centers
json.policies @result.policies.as_json

json.custom_fields do
  json.array!(@result.custom_field_configurations) do |fc|
    json.field_name fc.field_name
    json.id fc.id
    json.field_type fc.field_type
    json.field_key fc.field_key
    case fc.field_type_id
    when FieldType.id_for(:drop_down)
      json.drop_down_items fc.drop_down_items
    when FieldType.id_for(:multiselect)
      json.drop_down_items fc.multiselect_items
    else
      # do nothing?
    end
  end
end