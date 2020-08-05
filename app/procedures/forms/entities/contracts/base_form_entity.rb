require 'reform/form/dry'
class Forms::Entities::Contracts::BaseFormEntity < Reform::Form

  feature Reform::Form::Dry # override the default activemodel validation
  # property :form_id # Cannot be changed
  # property :form_section_id # Cannot be changed

  validation do
    params do
      optional(:placeholder)
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
  end

  property :entity_key # Cannot be changed for system fields
  property :label
  property :placeholder
  property :hint, deserializer: -> (input, represented, *args){ represented.hint = "Enter Value" if input[:hint].blank? }
  property :position

  property :behavior, virtual: true
  property :editable, deserializer: -> (input, represented, *args) {represented.editable = input.dig(:behavior)&.dig(:editable) if (represented.model.persisted? and represented.model.can_editable_be_changed) or true}
  property :required, deserializer: -> (input, represented, *args) {represented.required = input.dig(:behavior)&.dig(:required) if (represented.model.persisted? and represented.model.can_required_be_changed) or true}
  property :active, deserializer: -> (input, represented, *args) {represented.active = input.dig(:behavior)&.dig(:active) if (represented.model.persisted? and represented.model.can_be_disabled) or true}
  property :visible, deserializer: -> (input, represented, *args) {represented.visible = input.dig(:behavior)&.dig(:visible) if (represented.model.persisted? and represented.model.can_visible_be_changed) or true}

  property :unique, deserializer: -> (input, represented, *args){ represented.unique = input[:unique] if (represented.model.persisted? and represented.model.can_uniqueness_be_changed) or true }
  property :default_value, deserializer: -> (input, represented, *args) { represented.default_value = input[:default_value] if (input[:default_value].present? || (input[:default_value].nil? and ((represented.model.persisted? and represented.model.allow_clearing_default_value) or true)))}

  # property :system_field
  # property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.current_user.company_id}
  # property :entity_path #todo populate it - model level
  # property :parent_id # Handled in sub classes
  # property :config_path #todo

  property :current_user, virtual: true
  property :options

  # Computation
  property :compute_enabled
  property :compute_type_id
  property :compute_formula
  property :compute_lookup_entity_id

  # Validations
  collection :validations, populator: :validations! do
    property :id
    # property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
    # property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
    property :error_message
    property :updated_by_id, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.contract_root.current_user.id}
    # property :validation_id  # ignored in case of custom fields
    property :custom # doubt # todo - replace with system validation
    property :internal # todo - migration to remove
    property :is_updated
    property :rule_text, virtual: true
    property :rule, deserializer: -> (input, represented, *args){ represented.rule = Rules::Adapters::Store.load(represented.rule_text) } #todo - validate rule
    property :can_be_updated # goes for system field
  end

  # Conditions
  collection :conditions, populator: :conditions! do
    property :id
    property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
    property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
    property :created_by_id, deserializer: -> (input, represented, *args) {represented.created_by_id = represented.contract_root.current_user.id}
    property :updated_by_id, deserializer: -> (input, represented, *args) {represented.updated_by_id = represented.contract_root.current_user.id}
    property :condition_id
    property :custom
    property :internal
    property :is_updated
    property :can_be_updated
    property :rule_text, virtual: true
    property :rule, deserializer: -> (input, represented, *args){ represented.rule = Rules::Adapters::Store.load(represented.rule_text) }
    property :referencable_id
    property :referencable_type

    collection :actions, populator: :actions! do
      property :id
      property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
      property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
      property :property#, validates: {presence: true}
      property :value#, validates: {presence: true, inclusion: {in: [true, false]}}
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

    condition || conditions.append(FormEntityValidation.new)
  end

end
