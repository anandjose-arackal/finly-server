require "reform/form/validation/unique_validator"

class Masters::Schema::Entity::Contract < Reform::Form

  # property :master_schema, deserializer: -> (input, represented, **) {
  #   represented.master_schema ||= represented.contract_parent&.model
  # }
  property :company, deserializer: -> (input, represented, **) {
    represented.company ||= represented.contract_parent&.model&.company
  }
  property :type, deserializer: -> (input, represented, **) {
    type = represented.type
    type = input[:entity_type] if represented.type.blank?
    if type.is_a?(String)
      if type.starts_with?("MasterEntity")
        represented.type = Object.const_get(type)
      else
        represented.type = Masters::Entity::Registry.types[type]
      end
    else
      represented.type = type
    end
    if represented.type.blank?
      debugger
    end
  }
  property :hint, deserializer: -> (input, represented, **) {
    represented.hint = input[:hint] || represented.type&.schema&.dig(:hint)
  }
  property :required, default: false
  property :unique, default: false
  property :primary_key, default: false
  property :position
  property :label, deserializer: -> (input, represented, **) {
    represented.label = input[:label] if input[:label].present?
    represented.label ||= represented.entity_key.to_s.titleize
  }
  property :system_entity, deserializer: -> (input, represented, **) {
    represented.system_entity ||= false
  }
  property :entity_key, deserializer: -> (input, represented, **) {
    if input[:entity_key].present? and not represented.system_entity
      # entity_key cannot be modified once set
      represented.entity_key ||= input[:entity_key]
    end
  }
  property :active, default: true
  property :show_in_lookup, default: false
  property :options, deserializer: -> (input, represented, **) {
    represented.options ||= {}
    represented.model.class.options.each do |key, value|
      if input[key].present?
        represented.options[key] = input[key]
      elsif represented.options[key].blank? and value[:default].present? and not value[:default] == NoObject
        represented.options[key] = value[:default]
      end
    end
  }
  property :choices_scope
  collection :choices, populate_if_empty: MasterEntityChoice do
    property :company, deserializer: -> (input, represented) {
      represented.company ||= contract_root.model.company
    }
    property :created_by, deserializer: -> (input, represented) {
      represented.created_by ||= contract_root.model.created_by
    }
    property :name
  end

  property :can_label_be_changed, deserializer: -> (input, represented, **) {
    represented.can_label_be_changed = true unless represented.system_entity
  }
  property :can_uniqueness_be_changed, deserializer: -> (input, represented, **) {
    represented.can_uniqueness_be_changed = true unless represented.system_entity
  }
  property :can_required_be_changed, deserializer: -> (input, represented, **) {
    represented.can_required_be_changed = true unless represented.system_entity
  }
  property :can_active_be_changed, deserializer: -> (input, represented, **) {
    represented.can_active_be_changed = true unless represented.system_entity
  }
  property :can_be_destroyed, deserializer: -> (input, represented, **) {
    represented.can_be_destroyed = true unless represented.system_entity
  }


  validates :type, presence: true
  validates :hint, presence: true
  # validates :master_schema, presence: true
  validates :entity_key, presence: true
  # validates_uniqueness_of :entity_key, scope: [:master_schema]
  validates :label, presence: true
  validates :type, presence: true

  validate :primary_key_should_be_unique
  validate :non_system_entity_keys

  def primary_key_should_be_unique
    if primary_key and not unique
      errors.add :primary_key, 'should be unique'
    end
  end

  def non_system_entity_keys
    return if system_entity

    fields = contract_root.system_master ? MasterEntity::SYSTEM_MASTER_CUSTOM_FIELDS : MasterEntity::CUSTOM_MASTER_CUSTOM_FIELDS
    unless fields.include?(entity_key)
      errors.add :entity_key, 'is not valid'
    end
  end

end