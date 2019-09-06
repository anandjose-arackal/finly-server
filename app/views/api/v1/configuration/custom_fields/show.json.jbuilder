json.data do
  field_configuration = @result.field_configuration
  json.extract! field_configuration, :id, :field_name, :enabled, :mandatory,
                :global, :field_type, :field_parent_types
  if field_configuration.drop_down?
    json.drop_down_items do
      json.array! field_configuration.drop_down_items.exclude_deleted
    end
  end
  if field_configuration.multiselect?
    json.multiselect_items do
      json.array! field_configuration.multiselect_items.exclude_deleted
    end
  end
  json.configurable do
    json.type field_configuration.configurable_type
    if field_configuration.configurable&.class&.name == 'Policy'
      json.policy do
        json.id field_configuration.configurable.id
        json.name field_configuration.configurable.name
      end
    end
  end
end