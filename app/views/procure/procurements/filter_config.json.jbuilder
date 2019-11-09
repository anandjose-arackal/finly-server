json.merge! @result.config

json.po_statuses do
  json.array! @result.po_statuses do |status|
    json.extract! status, :id, :name
    json.display_name status.name.humanize
  end
end

json.invoice_statuses do
  json.array! @result.invoice_statuses do |status|
    json.extract! status, :id, :name
    json.display_name status.name.humanize
  end
end

json.locations do 
  json.array! @result.locations do |location|
    # json.extract! location, :id, :name
    json.merge! location.as_json(tree: true)
  end
end

json.departments do
  json.array! @result.departments do |department|
    # json.extract! department, :id, :name, :cost_center_id
    json.merge! department.as_json(tree: true)
  end
end

json.sub_departments do
  json.array! @result.sub_departments do |dept|
    json.extract! dept, :id, :name, :cost_center_id
    json.parent_id dept.ancestry&.to_i
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

json.custom_fields do
  json.array!(@result.po_custom_fields_config) do |fc|
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
