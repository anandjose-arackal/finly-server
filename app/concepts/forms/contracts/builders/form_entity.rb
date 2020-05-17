class Forms::Contracts::Builders::FormEntity < Transactions::API

  SETTER_ACTIONS = %w(editable visible).freeze
  VALIDATION_ACTIONS = %w(required unique).freeze

  # attr_accessor :entity
  #
  # def self.call(entity, reform)
  #   entity_builder = self.new(entity)
  #   entity_builder.contract(reform)
  #   entity_builder
  # end
  #
  # def initialize(entity)
  #   self.entity = entity
  # end
  #
  # def contract(reform)
  #   define_property(reform)
  #   define_choice_dependencies(reform)
  #   define_validations(reform)
  #   execute_contract_evaluators(reform)
  # end

  schema do
    params do
      required(:reform).filled
      required(:entity).filled
    end
  end

  pass :init
  pass :define_entity
  pass :validate_entity
  pass :validate_choices
  pass :execute_contract_evaluators

  def init(context, params:, **)
    context[:reform] = params[:reform]
    context[:entity] = params[:entity]
  end

  def define_entity(context, reform:, entity:, current_user:, **)
    # debugger
    # type = entity.collection ? :collection : :property
    type = :property
    block = contract_block(entity, current_user)
    if block.present?
      reform.send(type, entity.entity_key, properties(entity), &block)
    else
      reform.send(type, entity.entity_key, properties(entity))
    end
  end

  def validate_entity(context, reform:, entity:, **)
    reform.validate -> do
      # Using as_nested_hash instead of input as the input need not always
      result = Forms::Contracts::Helpers::ConditionChecker.(
          entity.form.conditions, entity, VALIDATION_ACTIONS, form: contract_root.to_nested_hash, row: to_nested_hash
      )
      required = result['required'] || entity.required

      if required and send(entity.entity_key).blank?
        errors.add entity.entity_key, 'cannot be blank'
      end

      entity.form.validations.each do |validation|
        next unless validation.entity_path == entity.entity_path
        next unless validation.rule.apply?({form: contract_root.to_nested_hash, row: to_nested_hash}.with_indifferent_access)
        errors.add entity.entity_key, validation.error_message
      end
    end
  end

  def validate_choices(context, reform:, entity:, **)

  end

  def execute_contract_evaluators(context, reform:, entity:, **)
    context = {
        entity: entity,
        reform: reform
    }
    entity.class.contract_evaluators.each do |name, evaluator|
      evaluator.call(context)
    end
  end

  protected

  def properties(entity)
    properties = {}
    properties[:virtual] = true if entity.custom_field
    properties[:populate_if_empty] = entity.populate_if_empty if entity.populate_if_empty.present?
    properties[:deserializer] = deserializer(entity) unless entity.entity_type.to_s == 'data_map'
    properties
  end

  def deserializer(ent)
    entity = ent
    lambda do |input, represented, **|
      # -> Conditions like editable / visible are checked for deserialization
      result = Forms::Contracts::Helpers::ConditionChecker.(entity.form.conditions, entity, SETTER_ACTIONS, form: represented.contract_input, row: input)
      editable = result['editable'] || entity.editable
      visible = result['visible'] || entity.visible

      if editable and visible and input.has_key?(entity.entity_key)
        value = input[entity.entity_key]# || entity.default_value
        represented.send("#{entity.entity_key}=", value)
      else
        value = represented.send(entity.entity_key)
      end

      # -> Computations are run here
      if visible and not editable and entity.compute_enabled
        Forms::Contracts::Helpers::ComputeRunner.(represented, entity, value, form: represented.contract_input, row: input)
      end
    end
  end

  def contract_block(entity, user)
    return nil unless entity.entities.present?

    entities = entity.entities

    lambda do |*args|
      Forms::Contracts::Builders::CustomField.(self, entities.custom_fields) if entity.associate_custom_fields

      entities.each do |ent|
        ent.contract(self, user)
      end
    end
  end
end