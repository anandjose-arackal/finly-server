require 'reform/form/dry'

class Masters::Entity::Contract < Reform::Form
  feature Reform::Form::Dry

  validation do
    params do
      required(:master_schema).filled
      required(:entity_key).filled
      required(:label).filled
    end
  end

  property :master_schema
  property :parent_id, deserializer: ->(input, represented, **) {
    represented.parent_id = input[:parent_id] if input[:parent_id].present? and represented.schema&.can_attributes_be_nested
  }
  property :company_id
  property :hint
  property :required, default: false
  property :unique, default: false
  property :position
  property :entity_key
  property :label, deserializer: -> (input, represented, **) {
    represented.label = input[:label] if input[:label].present?
    represented.label ||= represented.entity_key.to_s.titleize
  }
  property :active, default: true
  property :show_in_lookup, default: false

  class Masters::Entity::Contract::Custom < Masters::Entity::Contract

    property :can_label_be_changed, value: true
    property :can_uniqueness_be_changed, value: true
    property :can_mandatory_be_changed, value: true
    property :can_active_be_changed, value: true
    property :can_be_destroyed, value: true

  end

  class Masters::Entity::Contract::System < Masters::Entity::Contract

    property :can_label_be_changed, default: true
    property :can_uniqueness_be_changed, default: false
    property :can_mandatory_be_changed, default: false
    property :can_active_be_changed, default: true
    property :can_be_destroyed, default: false

  end

end