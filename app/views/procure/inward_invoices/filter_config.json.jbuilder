json.locations do 
  json.array! @result.locations do |location|
    json.merge! location.as_json(tree: true)
  end
end

json.departments do
  json.array! @result.departments do |department|
    json.merge! department.as_json(tree: true)
  end
end

json.cost_centers do
  json.array! @result.cost_centers do |cost_center|
  json.extract! cost_center, :id, :name
  end
end

json.policies do |policy|
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end

# json.invoice_custom_fields_config @result.custom_fields_config[:invoice]

json.invoice_custom_fields do
  json.array!(@result.invoice_custom_field_configurations) do |fc|
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

json.agreement_invoice_enabled @result.agreement_invoice_enabled