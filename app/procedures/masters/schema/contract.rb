# This contract validates system and custom MasterSchema's
class Masters::Schema::Contract < Reform::Form

  property :name
  property :master_key
  property :company_id, deserializer: -> (input, represented, **) {}
  property :klass_name, deserializer: -> (input, represented, **) {}

  # This property cannot be set from the contract. It can only be set directly in the model, which is done by the DSL
  property :system_master, deserializer: -> (input, represented, **) {
    represented.system_master ||= false
  }
  property :active, default: true
  property :primary_entity_key

  # This property cannot be set from the contract. It can only be set directly in the model, which is done by the DSL
  property :can_name_be_changed, deserializer: -> (input, represented, **) {
    represented.can_name_be_changed = true unless represented.system_master
  }

  # This property cannot be set from the contract. It can only be set directly in the model, which is done by the DSL
  property :can_attributes_be_changed, deserializer: -> (input, represented, **) {
    represented.can_attributes_be_changed = true unless represented.system_master
  }

  # Every entity type uses a different contract. MasterEntity::Text validates the min_length and max_length while
  # MasterEntity::Sequence validates the presence of prefix and min_length
  #
  # Since build_twin is responsible for building the necessary sub_contracts, we can achieve this feature
  # by overriding build_twin to return the correct contract instance  depending on the entity type.
  #
  # Reference: #build_twin
  collection :entities, populate_if_empty: MasterEntity do #, form: ProxyContract
  end

  # Identifies the entity for which primary_key flag is set. This validates that exactly one entity has primary_key set.
  validate :set_primary_key
  validates :name, presence: true
  validates :master_key, presence: true #, unique: {scope: [:company_id]}
  validates_uniqueness_of :master_key, scope: [:company_id]

  # Iterates through the entities to validate that all entity_key's are unique.
  validate :entity_key_uniqueness

  # If system_master is true, then +klass_name+ is mandatory
  validates :klass_name, presence: true, if: -> { self.system_master }

  # We override build_twin method to facilitate initializing different contract for different entity types
  def build_twin(dfn, value, options = {})
    return super(dfn, value, options) unless value.is_a?(MasterEntity)

    properties = {
        contract_parent: self,
        contract_root: self.contract_root,
    }
    value.schema_contract.new(value, options.merge(properties))
  end

  def set_primary_key
    self.primary_entity_key = nil
    entities.each do |entity|
      if entity.primary_key
        if self.primary_entity_key.present?
          errors.add :primary_key, 'is set for more than one entities'
        else
          self.primary_entity_key = entity.entity_key
        end
      end
    end
    if self.primary_entity_key.blank?
      errors.add :primary_key, 'is not set'
    end
  end

  def entity_key_uniqueness
    used_keys = []
    entities.each do |entity|
      if used_keys.include?(entity.entity_key)
        errors.add :base, "Entity Key #{entity.entity_key} is not unique"
      end

      used_keys << entity.entity_key
    end
  end

end