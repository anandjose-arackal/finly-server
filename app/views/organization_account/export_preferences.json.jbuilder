json.export_preferences do
  json.array!(@result.export_preferences) do |export_preference|
    json.export_field_id export_preference.export_field_id
    json.export_field_name export_preference.export_field&.name
  end
end

json.export_fields do
  json.array!(@result.export_fields) do |export_field|
    json.id export_field.id
    json.name export_field.name
  end
end