class Masters::Schema::Contract < Reform::Form

  class EntityForm < Reform::Form
    property :master_schema, deserializer: -> (input, represented, **) {
      represented.master_schema ||= contract_root.model
    }
    property :company, deserializer: -> (input, represented, **) {
      represented.company ||= contract_root.model.company
    }
    property :type, deserializer: -> (input, represented, **) {
      represented.type ||= Masters::Entity::Registry.types[input[:type]]
    }

    validate :validate_contract

    def validate_contract
      master_entity_class = self.type.is_a?(String) ? Object.const_get(type) : type
      if master_entity_class.blank?
        errors.add :type, 'is invalid'
        return
      end

      contract = master_entity_class.build_schema_contract.new(self.model)
      unless contract.validate(contract_input)
        contract.errors.each do |key, value|
          errors.add key, value
        end
      end

      contract.sync
    end
  end

  property :name
  property :master_key
  property :model, deserializer: -> (input, represented, **) {}
  property :klass_name, deserializer: -> (input, represented, **) {}
  property :system_master, deserializer: -> (input, represented) {
    represented.system_master ||= false
  }
  property :active, default: true
  property :primary_entity_key
  property :can_name_be_changed, deserializer: -> (input, represented) {
    represented.can_name_be_changed = true unless represented.system_master
  }
  property :can_attributes_be_nested, deserializer: -> (input, represented) {
    represented.can_attributes_be_nested = true unless represented.system_master
  }
  property :can_attributes_be_changed, deserializer: -> (input, represented) {
    represented.can_attributes_be_changed = true unless represented.system_master
  }

  collection :entities, populate_if_empty: MasterEntity, form: EntityForm

  validate :set_primary_key
  validates :name, presence: true
  validates :master_key, presence: true

  # System schema validations
  validates :model, presence: true, if: -> { self.system_master }
  validates :klass_name, presence: true, if: -> { self.system_master }

  def set_primary_key
    self.primary_entity_key = nil
    entities.each do |entity|
      if entity.model.primary_key
        if self.primary_entity_key.present?
          errors.add :primary_key, 'is set for more than one entities'
        else
          self.primary_entity_key = entity.model.entity_key
        end
      end
    end
    if self.primary_entity_key.blank?
      errors.add :primary_key, 'is not set'
    end
  end

end