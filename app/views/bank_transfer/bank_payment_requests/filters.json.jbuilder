json.custom_fields do
  json.array!(@result.field_configurations, :field_name, :id, :field_type, :drop_down_items)
end
