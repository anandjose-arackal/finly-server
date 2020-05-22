class Forms::Contracts::Builders::FormEntity < Transactions::API

  SETTER_ACTIONS = %w(editable visible).freeze
  VALIDATION_ACTIONS = %w(required unique).freeze

  schema do
    params do
      required(:reform).filled
      required(:entity).filled
    end
  end

  pass :init
  pass :define_entity # Deserialize JSON to property unless the property has conditional editable/visible conditions
  pass :assign_and_compute_entity # Assign conditional editable/visible values + Run Computations on non-editable fields
  pass :validate_entity # Check System Validations
  pass :custom_validate_entity # Check Custom Validations
  pass :validate_choices # Validate all dropdown choices
  pass :execute_contract_evaluators # Contract evaluators help in checking entity specific validations such as max_items, min_items. Todo : Rename maybe?

  def init(context, params:, **)
    context[:reform] = params[:reform]
    context[:entity] = params[:entity]
  end

  def define_entity(context, reform:, entity:, current_user:, **)
    # type = entity.collection ? :collection : :property
    type = :property
    block = contract_block(entity, current_user)
    if block.present?
      reform.send(type, entity.entity_key, properties(entity), &block)
    else
      reform.send(type, entity.entity_key, properties(entity))
    end
  end

  def assign_and_compute_entity(context, reform:, entity:, **)
    return if entity.entities.present? # Nothing to assign if the entity has sub-entities

    reform.validate -> do
      row_data = Transactions::Contract.to_form(self)
      form_data = Transactions::Contract.to_form(contract_root)
      result = Forms::Contracts::Helpers::ConditionChecker.(entity.conditions, entity, SETTER_ACTIONS, form: form_data, row: row_data)
      editable = result['editable']
      visible = result['visible']
      if editable and visible and row_data.has_key?(entity.entity_key)
        value = row_data[entity.entity_key] # || entity.default_value
        send("#{entity.entity_key}=", value)
      end

      # -> Computations are run here
      if entity.compute_enabled and not editable
        value = send(entity.entity_key)
        Forms::Contracts::Helpers::ComputeRunner.(self, entity, value, form: form_data, row: row_data)
      end
    end
  end

  def validate_entity(context, reform:, entity:, **)
    reform.validate -> do
      # Using as_nested_hash instead of input as the input need not always
      result = Forms::Contracts::Helpers::ConditionChecker.(
          entity.conditions, entity, VALIDATION_ACTIONS, form: Transactions::Contract.to_form(contract_root), row: Transactions::Contract.to_form(self)
      )
      required = result['required']

      # Required validation ( System Validation )
      if required and send(entity.entity_key).blank?
        errors.add entity.entity_key, 'cannot be blank'
      end
    end
  end

  def custom_validate_entity(context, reform:, entity:, **)
    reform.validate -> do
      entity.validations.each do |validation|
        next unless validation.rule.apply?({form: Transactions::Contract.to_form(contract_root), row: Transactions::Contract.to_form(self)}.with_indifferent_access)

        errors.add entity.entity_key, validation.error_message
      end
    end
  end

  def validate_choices(context, reform:, entity:, current_user:, **)
    # Choices scope is used to determine if the form has choices or not
    return unless entity.choices_scope.present?

    # controlling_choices
    reform.validate -> do
      form_data = Transactions::Contract.to_form(contract_root)
      row_data = Transactions::Contract.to_form(self)
      entity_value = Forms::RequestParser.new(form: form_data, row: row_data).fetch(entity.entity_path)
      result = Forms::Ops::Choices.(
          params: {
              form_data: form_data,
              row_data: row_data,
              entity_path: entity.entity_path,
              form_record: entity.form,
              qs: {id_in: entity_value} # Pass the ID as a simple filter
          }, current_user: current_user
      )
      unless result[:choices].data.present?
        errors.add entity.entity_key, 'has an invalid choice'
      end
    end
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
    properties[:deserializer] = deserializer(entity) unless entity.entities.present?
    properties
  end

  def deserializer(ent)
    entity = ent
    lambda do |input, represented, **|
      next unless input.has_key?(entity.entity_key)

      # -> Conditions like editable / visible are checked for deserialization
      # Check if conditional editable / visible is applicable on the entity, assign unless editable / visible can be modified
      dynamic_editable = false
      dynamic_visible = false
      entity.conditions.each do |condition|
        condition.actions.each do |action|
          dynamic_editable ||= (action.property == 'editable')
          dynamic_visible ||= (action.property == 'visible')
        end
      end

      next if dynamic_editable
      next if dynamic_visible
      next unless entity.editable
      next unless entity.visible

      # Assign value only if conditional editable/visible does not apply the field
      represented.send("#{entity.entity_key}=", input[entity.entity_key])
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