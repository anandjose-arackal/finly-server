class Forms::Contracts::Builders::FormEntity

  SETTER_ACTIONS = %w(editable visible).freeze
  VALIDATION_ACTIONS = %w(required unique).freeze

  attr_accessor :entity

  def self.call(entity, reform)
    entity_builder = self.new(entity)
    entity_builder.contract(reform)
    entity_builder
  end

  def initialize(entity)
    self.entity = entity
  end

  def contract(reform)
    define_property(reform)
    define_choice_dependencies(reform)
    define_validations(reform)
    execute_contract_evaluators(reform)
  end

  protected

  def define_property(reform)
    # debugger
    # type = entity.collection ? :collection : :property
    type = :property
    block = contract_block(entity)
    if block.present?
      reform.send(type, entity.entity_key, properties(entity), &block)
    else
      reform.send(type, entity.entity_key, properties(entity))
    end
  end

  def define_validations(reform)
    entity = self.entity
    reform.validate -> do
      row = {}
      row[entity.entity_key] = self.send(entity.entity_key)
      result = Forms::Contracts::Helpers::ConditionChecker.run(entity.form.conditions, entity, VALIDATION_ACTIONS, form: contract_input, row: row)
      required = result['required'] || entity.required

      if required and send(entity.entity_key).blank?
        errors.add entity.entity_key, 'cannot be blank'
      end

    end
  end

  def execute_contract_evaluators(reform)
    context = {
        entity: entity,
        reform: reform
    }
    entity.class.contract_evaluators.each do |name, evaluator|
      evaluator.call(context)
    end
  end

  def define_choice_dependencies(reform)

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
      result = Forms::Contracts::Helpers::ConditionChecker.run(entity.form.conditions, entity, SETTER_ACTIONS, form: represented.contract_input, row: input)
      editable = result['editable'] || entity.editable
      visible = result['visible'] || entity.visible

      if editable and visible
        value = input[entity.entity_key] || entity.default_value
        represented.send("#{entity.entity_key}=", value)
      end

      # -> Computations are run here
      # if visible and entity.server_computation
      #
      # end
    end
  end

  def contract_block(entity)
    return nil unless entity.entities.present?

    entities = entity.entities

    lambda do |*args|
      Forms::Contracts::Builders::CustomField.(self, entities.custom_fields) if entity.associate_custom_fields

      entities.each do |ent|
        ent.contract(self)
      end
    end
  end
end