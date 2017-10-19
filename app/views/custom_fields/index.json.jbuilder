json.array! @result.field_configurations do |config|
  json.extract! config, :id, :field_name, :enabled, :mandatory,
                :global, :field_type, :field_parent_type
  if config.drop_down?
    json.drop_down_items do
      json.array! config.drop_down_items.exclude_deleted
    end
  end
  json.configurable do
    json.type config.configurable_type
    if config.configurable&.class.name == 'Policy'
      json.policy do
        json.id config.configurable.id
        json.name config.configurable.name
      end
    end
  end
end