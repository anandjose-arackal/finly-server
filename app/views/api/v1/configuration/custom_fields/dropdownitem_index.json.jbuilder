json.data do
  field_configuration = @result.field_configuration
  json.extract! field_configuration, :id, :field_name, :enabled
    json.drop_down_items do
      json.array! @result.drop_down_items
    end
end