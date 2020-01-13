json.vendor_types do
  json.array! @result.vendor_types, :id, :name
end

if @result.policies.present?
  
end

if @result.vendor_empanelment_workflow_enabled
  json.policies do
    json.array! @result.policies do |policy|
      json.extract! policy, :id, :name
    end
  end

  json.statuses do
    json.array! @result.vendor_statuses do |status|
      json.merge! status.as_json
    end
  end
end

json.custom_fields do
  json.array!(@result.vendor_custom_fields_config) do |fc|
    json.field_name fc.field_name
    json.id fc.id
    json.field_type fc.field_type
    json.field_key fc.field_key
    case fc.field_type_id
      when FieldType.id_for(:drop_down)
        json.drop_down_items fc.drop_down_items
      when FieldType.id_for(:multiselect)
        json.drop_down_items fc.multiselect_items
    end
  end
end
