require 'reform/form/dry'
class Forms::Entities::Contracts::BaseFormEntity < Reform::Form
  feature Reform::Form::Dry # override the default activemodel validation

  property :form_id, deserializer: -> (input, represented, *args) {} # Cannot be changed
  property :form_section_id, deserializer: -> (input, represented, *args) {} # Cannot be changed
  property :id
  property :uuid


  validation do
    params do
      optional(:id)
      optional(:uuid)
      optional(:placeholder)
      required(:form_id).filled
      required(:form_section_id).filled
      required(:entity_key).filled
      required(:label).filled
      optional(:placeholder)
      optional(:hint)
      optional(:position) # Position will be saved in a different API Call
      required(:behavior).filled do
        hash do
          required(:editable).filled
          required(:visible).filled
          required(:active).filled
          required(:required).filled
        end
      end
    end

    rule(:entity_key, :form_id, :uuid, :id) do
      # Checks uniqueness of entity_key within a form
      entity = Form.find_by(uuid: values[:form_id])&.entities.find_by(entity_key: values[:entity_key])
      if entity.present?
        uuid = values[:uuid] || values[:id]
        if entity.uuid != uuid
          key.failure('must be unique within a form')
        end
      end
    end
  end

  property :entity_key, deserializer: -> (input, represented, *args) {represented.entity_key = input[:entity_key] if represented.entity_key.blank?}
  property :label
  property :placeholder
  property :hint, deserializer: -> (input, represented, *args) {represented.hint = input[:hint].blank? ? "Enter Value" : input[:hint]}
  property :position
  property :behavior, virtual: true

  property :behavior, virtual: true

  property :editable, deserializer: -> (input, represented, *args) {represented.editable = input.dig(:behavior, :editable) if (represented.model.persisted? and represented.model.can_editable_be_changed) or true}
  property :required, deserializer: -> (input, represented, *args) {represented.required = input.dig(:behavior, :required) if (represented.model.persisted? and represented.model.can_required_be_changed) or true}
  property :active, deserializer: -> (input, represented, *args) {represented.active = input.dig(:behavior, :active) if (represented.model.persisted? and represented.model.can_be_disabled) or true}
  property :visible, deserializer: -> (input, represented, *args) {represented.visible = input.dig(:behavior, :visible) if (represented.model.persisted? and represented.model.can_visible_be_changed) or true}

  property :unique, deserializer: -> (input, represented, *args){ represented.unique = input[:unique] if (represented.model.persisted? and represented.model.can_uniqueness_be_changed) or true }
  property :default_value, deserializer: -> (input, represented, *args) { represented.default_value = input[:default_value] if (input[:default_value].present? || (input[:default_value].nil? and ((represented.model.persisted? and represented.model.allow_clearing_default_value) or true)))}

  # property :system_field
  # property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.current_user.company_id}
  # property :parent_id # Handled in sub classes

  property :current_user, virtual: true
  # property :options, deserializer: -> (input, represented, *args) {represented.options = {} if input[:options].blank?}
  property :options, deserializer: -> (input, represented, *args) {represented.options = input[:options].is_a?(Hash) ? input[:options] : {}}

  # Computation
  property :compute_enabled
  property :compute_type_id
  property :compute_formula
  property :compute_lookup_entity_id

  # Validations
  collection :validations, populator: :validations! do
    property :id
    property :company_id, deserializer: -> (input, represented, *args) {represented.company_id ||= represented.contract_root.current_user.company_id}
    property :form_id, deserializer: -> (input, represented, *args) {represented.form_id ||= represented.contract_root.form_id}
    property :error_message
    property :updated_by_id, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.contract_root.current_user.id}
    # property :validation_id  # ignored in case of custom fields
    # property :custom # doubt # todo - replace with system validation
    property :system_validation, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.system_validation ? represented.system_validation : false} # todo - migration to remove
    property :is_updated
    property :rule, deserializer: -> (input, represented, *args) {represented.rule = Rules::Adapters::Store.load(input[:rule])}
    property :can_be_updated # goes for system field

    validation do
      params do
        required(:rule).filled
        required(:error_message).filled
      end

      rule(:error_message) do
        key.failure("cannot be greater than 256 characters") if value.length > 256
      end
    end
  end

  # Conditions
  collection :conditions, populator: :conditions! do
    property :id
    property :company_id, deserializer: -> (input, represented, *args) {represented.company_id ||= represented.contract_root.current_user.company_id}
    property :form_id, deserializer: -> (input, represented, *args) {represented.form_id ||= represented.contract_root.form_id}
    property :created_by_id, deserializer: -> (input, represented, *args) {represented.created_by_id = represented.contract_root.current_user.id}
    property :updated_by_id, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.contract_root.current_user.id}
    # property :condition_id
    property :custom
    property :internal
    property :is_updated
    property :can_be_updated
    # property :rule_text, virtual: true
    property :rule, deserializer: -> (input, represented, *args) {represented.rule = Rules::Adapters::Store.load(input[:rule])}
    property :referencable_id
    property :referencable_type

    collection :actions, populator: :actions! do
      property :id
      property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
      property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
      property :property#, validates: {presence: true}
      property :value, deserializer: -> (input, represented, *args) {represented.value = ['true', true, 1, '1', 'TRUE', 'True'].include?(input[:value]) ? '1' : '0'}

      validation :condition_actions do
        params do
          required(:property).filled
          required(:value).filled
        end
      end
    end

    validation :conditions do
      params do
        required(:rule).filled
        required(:actions).filled
      end
    end

    def actions!(collection:, fragment:, index:, options:, **)

      action = actions.find {|action| action.id.present? and action.id.to_s == fragment["id"].to_s}

      if fragment["_destroy"]
        actions.destroy(action)
        return skip!
      end

      action || actions.append(FormConditionAction.new)
    end
  end

  # validates :compute_type_id, :inclusion => {in: FormEntityComputationType.pluck(:id) }
  def validations!(collection:, fragment:, index:, options:, **)
    validation = validations.find {|validation| validation.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      validations.destroy(validation)
      return skip!
    end

    validation || validations.append(FormEntityValidation.new)
  end

  def conditions!(collection:, fragment:, index:, options:, **)
    condition = conditions.find {|condition| condition.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      conditions.destroy(condition)
      return skip!
    end

    condition || conditions.append(FormCondition.new)
  end

end
