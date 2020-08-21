class Masters::Schema::Contract < Reform::Form

  property :name
  property :master_key
  property :company_id, deserializer: -> (input, represented, **) {}
  property :klass_name, deserializer: -> (input, represented, **) {}
  property :system_master, deserializer: -> (input, represented, **) {
    represented.system_master ||= false
  }
  property :active, default: true
  property :primary_entity_key
  property :can_name_be_changed, deserializer: -> (input, represented, **) {
    represented.can_name_be_changed = true unless represented.system_master
  }
  property :can_attributes_be_changed, deserializer: -> (input, represented, **) {
    represented.can_attributes_be_changed = true unless represented.system_master
  }

  # Identifying the correct form is done by overriding build_twin
  collection :entities, populate_if_empty: MasterEntity do #, form: ProxyContract
  end
  validate :set_primary_key
  validates :name, presence: true
  validates :master_key, presence: true #, unique: {scope: [:company_id]}
  validates_uniqueness_of :master_key, scope: [:company_id]

  validate :entity_key_uniqueness

  # System schema validations
  validates :klass_name, presence: true, if: -> { self.system_master }

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