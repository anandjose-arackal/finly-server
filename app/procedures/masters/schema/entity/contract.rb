require 'reform/form/dry'

class Masters::Schema::Entity::Contract < Reform::Form
  feature Reform::Form::Dry

  validation do
    params do
      required(:master_schema).filled
      required(:entity_key).filled
      required(:label).filled
      optional(:unique).value(:bool?)
      optional(:primary_key).value(:bool?)
    end

    rule :unique do
      if values[:primary_key] and not value
        key.failure 'should be set for primary key'
      end
    end
  end

  property :master_schema
  property :company_id
  property :hint
  property :required, default: false
  property :unique, default: false
  property :primary_key, default: false
  property :position
  property :entity_key
  property :label, deserializer: -> (input, represented, **) {
    represented.label = input[:label] if input[:label].present?
    represented.label ||= represented.entity_key.to_s.titleize
  }
  property :system_entity, deserializer: -> (input, represented, **) {
    represented.system_entity ||= false
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
    property :created_by, deserializer: -> (input, represented) { ``
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
  property :can_mandatory_be_changed, deserializer: -> (input, represented, **) {
    represented.can_mandatory_be_changed = true unless represented.system_entity
  }
  property :can_active_be_changed, deserializer: -> (input, represented, **) {
    represented.can_active_be_changed = true unless represented.system_entity
  }
  property :can_be_destroyed, deserializer: -> (input, represented, **) {
    represented.can_be_destroyed = true unless represented.system_entity
  }

end