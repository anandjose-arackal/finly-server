json.array! @result.field_configurations do |field_configuration|
  json.extract! field_configuration, :id, :field_name, :enabled, :mandatory,
                :global, :field_type, :field_parent_types
  if field_configuration.drop_down?
    json.drop_down_items do
      json.array! field_configuration.drop_down_items.exclude_deleted
    end
  end
  json.configurable do
    json.type field_configuration.configurable_type
    json.policies field_configuration.policies
  end
end