class Forms::Generators::Contract::FormEntity

  def contract(reform, entity)
    define_property(reform, entity)
    define_validations(reform, entity)
  end

  protected

  def define_property(reform, entity)
    type = entity.collection ? :collection : :property
    block = contract_block(entity)
    if block.present?
      reform.send(type, entity.entity_key, properties(entity), &block)
    else
      reform.send(type, entity.entity_key, properties(entity))
    end
  end

  def define_validations(reform, ent)
    entity = ent
    reform.validate -> do
      # value = self.send(entity.entity_key)
    end
  end

  def properties(entity)
    properties = {}
    properties[:virtual] = true if entity.custom_field
    properties[:populate_if_empty] = entity.populate_if_empty if entity.populate_if_empty.present?
    properties[:deserializer] = deserializer(entity)
    properties
  end

  def deserializer(ent)
    entity = ent
    lambda do |input, represented, **|
      # -> Conditions like editable / visible are checked for deserialization
      editable = entity.editable
      visible = entity.visible
      entity.form.conditions.each do |condition|
        next unless condition.entity_path == entity.entity_path
        applicable = false
        condition.actions.each do |action|

        end
      end
      if editable and visible
        represented = input[entity.entity_key]
      end

      # -> Computations are run here

    end
  end

  def contract_block(entity)
    return nil unless entity.entities.present?

    entity = self
    entities = self.entities

    lambda do |*args|
      instance_eval &Forms::Generators::Contract::CustomFieldMapper.setup(entities.custom_fields) if entity.associate_custom_fields

      entities.each do |ent|
        instance_eval &ent.contract(self, entity)
      end
    end
  end
end