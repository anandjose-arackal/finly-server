class Forms::Entities::Contracts::CustomFormEntity < Forms::Entities::Contracts::BaseFormEntity


  property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = input[:form_id] if represented.model.form_id.blank?}
  property :form_section_id
  property :entity_type, deserializer: -> (input, represented, *args) {represented.entity_type = input[:entity_type] if represented.model.entity_type.blank?}
  property :system_field # true if nil  #todo migration to rename field to system_field  #todo -search and destroy
  property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.current_user.company_id}

  property  :can_visible_be_changed, deserializer: -> (input, represented, *args) {represented.can_visible_be_changed = true}
  property  :can_editable_be_changed, deserializer: -> (input, represented, *args) {represented.can_editable_be_changed = true}
  property  :can_required_be_changed, deserializer: -> (input, represented, *args) {represented.can_required_be_changed = true}
  property  :can_uniqueness_be_changed, deserializer: -> (input, represented, *args) {represented.can_uniqueness_be_changed = true}
  property  :can_be_disabled, deserializer: -> (input, represented, *args) {represented.can_be_disabled = true}
  property  :can_label_be_renamed, deserializer: -> (input, represented, *args) {represented.can_label_be_renamed = true}
  property  :can_choices_be_changed, deserializer: -> (input, represented, *args) {represented.can_choices_be_changed = true}
  property  :allow_clearing_default_value, deserializer: -> (input, represented, *args) {represented.allow_clearing_default_value = true}

  # property :entity_path #todo populate it - model level
  property :parent_id
  # property :config_path #todo populate it - model level

end
