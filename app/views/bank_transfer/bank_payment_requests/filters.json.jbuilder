json.custom_fields do
  # json.array!(@result.field_configurations, :field_name, :id, :field_type, :drop_down_items)
  json.array!(@result.field_configurations) do |fc|
    json.field_name fc.field_name
    json.id fc.id
    json.field_type fc.field_type
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
