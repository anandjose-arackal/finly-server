json.result do
  entity = @op['model']

  json.id entity.id
  json.uuid entity.uuid
  json.company_id entity.company_id
  json.form_id entity.form_id
  json.form_section_id entity.form_section_id
  json.created_by_user_id entity.created_by_user_id
  json.entity_key entity.entity_key
  json.label entity.label
  json.placeholder entity.placeholder
  json.hint entity.hint
  json.entity_type entity.entity_type
  json.default_value entity.default_value
  json.behavior do
    json.editable entity.editable
    json.required entity.required
    json.active entity.active
    json.visible entity.visible
  end
  json.unique entity.unique
  json.position entity.position
  json.system_field entity.system_field
  json.can_visible_be_changed entity.can_visible_be_changed
  json.can_editable_be_changed entity.can_editable_be_changed
  json.can_required_be_changed entity.can_required_be_changed
  json.can_uniqueness_be_changed entity.can_uniqueness_be_changed
  json.can_be_disabled entity.can_be_disabled
  json.can_label_be_renamed entity.can_label_be_renamed
  json.can_choices_be_changed entity.can_choices_be_changed
  json.allow_clearing_default_value entity.allow_clearing_default_value
  json.options entity.options
  json.deleted_at entity.deleted_at
  json.created_at entity.created_at
  json.updated_at entity.updated_at
  json.internal entity.internal
  json.is_modified entity.is_modified
  json.entity_path entity.entity_path
  json.parent_id entity.parent_id
  json.populate_if_empty entity.populate_if_empty
  json.type entity.type
  json.config entity.config
  json.associate_custom_fields entity.associate_custom_fields
  json.compute_enabled entity.compute_enabled
  json.compute_type_id entity.compute_type_id
  json.compute_formula entity.compute_formula
  json.compute_lookup_entity_id entity.compute_lookup_entity_id
  json.filters entity.filters
  json.config_path entity.config_path
  json.validations entity.validations do |validation|
    json.id validation.id
    json.rule validation.rule&.as_store
    json.error_message validation.error_message
  end
  json.conditions entity.conditions do |condition|
    json.id condition.id
    json.rule condition.rule&.as_store
    json.actions condition.actions
  end
  json.choices entity.choices.as_json
end
# json.conditions do
#   entity.conditions.as_json
# end
#
# json.validations do
#   entity.validations.as_json
# end
# end
