class Forms::Contracts::Builders::FormEntity < Transactions::API

  SETTER_ACTIONS = %w(editable visible active internal).freeze
  VALIDATION_ACTIONS = %w(required unique).freeze

  schema do
    params do
      required(:contract).filled
      required(:entity).filled
    end
  end

  pass :init
  # Deserialize JSON to property + Run computations on non-editable fields.
  # Limitation: Since the deserialization happens sequentially, the computations will not consider the value
  # if the the field providing the data for computation is defined after the computed field
  pass :define_and_deserialize_entity
  # Check System Validations
  pass :validate_entity
  # Check Custom Validations
  pass :custom_validate_entity
  # Validate all dropdown choices
  pass :validate_choices
  # Contract evaluators help in checking entity specific validations such as max_items, min_items. Todo : Rename maybe?
  pass :execute_contract_evaluators

  def init(context, params:, **)
    context[:contract] = params[:contract]
    context[:entity] = params[:entity]
  end

  def define_and_deserialize_entity(context, contract:, entity:, current_user:, **)
    type = entity.class.collection? ? :collection : :property
    # type = :property
    block = contract_block(**context)
    if block.present?
      contract.send(type, entity.entity_key, properties(entity), &block)
    else
      contract.send(type, entity.entity_key, properties(entity))
    end
  end

  def validate_entity(context, contract:, entity:, **)
    contract.validate -> do
      # Using as_nested_hash instead of input as the input need not always
      result = Forms::Contracts::Helpers::ConditionChecker.(
          entity.conditions, entity, VALIDATION_ACTIONS, form: contract_root.to_form, row: self.to_form
      )
      required = result['required']

      # Required validation ( System Validation )
      if required and send(entity.entity_key).nil?
        errors.add entity.entity_key, 'cannot be blank'
      end
    end
  end

  def custom_validate_entity(context, contract:, entity:, **)
    contract.validate -> do
      entity.validations.each do |validation|
        next unless validation.rule.apply?({form: contract_root.to_form, row: self.to_form}.with_indifferent_access)

        errors.add entity.entity_key, validation.error_message
      end
    end
  end

  def validate_choices(context, contract:, entity:, current_user:, **)
    # Choices scope is used to determine if the form has choices or not
    return unless entity.choices_scope.present?

    # controlling_choices
    contract.validate -> do
      form_data = contract_root.to_form
      row_data = self.to_form
      entity_value = Forms::RequestParser.new(form: form_data, row: row_data).fetch(entity.entity_path)
      next if entity_value.blank?

      if entity.filters.blank? and entity.choice_dependencies.size == 0
        contract_root.bulk_validate_choice entity, entity_value
      else
        result = Forms::Ops::Choices.(
            params: {
                form_data: form_data,
                row_data: row_data,
                entity_path: entity.entity_path,
                form_record: entity.form,
                qs: {id_in: entity_value} # Pass the ID as a simple filter
            }, current_user: current_user
        )
        # Fixme: This is working only for lookup
        unless result[:choices].data.present?
          errors.add entity.entity_key, 'has an invalid choice'
        end
      end
    end
  end

  def execute_contract_evaluators(context, contract:, entity:, **)
    context = {
        entity: entity,
        contract: contract
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
    properties[:deserializer] = deserializer(entity) unless entity.class.layout?
    populator = entity.populator
    properties[:populator] = populator if populator.present?
    properties
  end

  def deserializer(ent)
    entity = ent
    lambda do |input, represented, **|
      # next unless input.has_key?(entity.entity_key)

      row_data = represented.to_form
      form_data = represented.contract_root.to_form
      result = Forms::Contracts::Helpers::ConditionChecker.(entity.conditions, entity, SETTER_ACTIONS, form: form_data, row: row_data)
      editable = result['editable']
      visible = result['visible']
      internal = result['internal']
      if editable and visible and row_data.has_key?(entity.entity_key)
        value = input[entity.entity_key] # || entity.default_value
        entity.populate(represented, value)
        # represented.send("#{entity.entity_key}=", entity.format(value))
      end


      # -> Computations are run here
      if entity.compute_enabled and (internal or not editable or not visible)
        represented.contract_root.queue_computation represented, entity
      end
    end
  end

  def contract_block(entity:, current_user:, **)
    return nil unless entity.class.layout?

    entities = entity.entities

    lambda do |*args|
      Forms::Contracts::Builders::CustomField.(self, entities.custom_fields) if entity.associate_custom_fields

      entities.each do |ent|
        Forms::Contracts::Builders::Form.setup_entity self, ent, current_user
      end
    end
  end
end