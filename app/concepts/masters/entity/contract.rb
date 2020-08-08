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