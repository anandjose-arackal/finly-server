
require 'reform/form/dry'
class Forms::Entities::Contracts::BaseFormEntity < Reform::Form

  feature Reform::Form::Dry # override the default activemodel validation
  # property :form_id # Cannot be changed
  # property :form_section_id # Cannot be changed
  property :entity_key # Cannot be changed
  property :label
  property :placeholder
  property :hint, deserializer: -> (input, represented, *args){ represented.hint = "Enter Value" if input[:hint].blank? }
  property :position

  property :behaviour, virtual: true

  property :editable, deserializer: -> (input, represented, *args){ represented.editable = input[:behavior][:editable] if represented.model.can_editable_be_changed }
  property :required, deserializer: -> (input, represented, *args){ represented.required = input[:behaviour][:required] if represented.model.can_required_be_changed }
  property :active, deserializer: -> (input, represented, *args){ represented.active = input[:behaviour][:active] if represented.model.can_be_disabled }
  property :visible, deserializer: -> (input, represented, *args){ represented.visible = input[:behaviour][:visible] if represented.model.can_visible_be_changed }
  property :unique, deserializer: -> (input, represented, *args){ represented.unique = input[:unique] if represented.model.can_uniqueness_be_changed }
  property :default_value, deserializer: -> (input, represented, *args) { represented.default_value = input[:default_value] if (input[:default_value].present? || (input[:default_value].nil? and represented.model.allow_clearing_default_value))}
  # property :system_field
  # property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.current_user.company_id}

  # property  :can_visible_be_changed, default: true
  # property  :can_editable_be_changed, default: true
  # property  :can_required_be_changed, default: true
  # property  :can_uniqueness_be_changed, default: true
  # property  :can_be_disabled, default: true
  # property  :can_label_be_renamed, default: true
  # property  :can_choices_be_changed, default: true
  # property  :allow_clearing_default_value, default: true

  # property :entity_path #todo populate it - model level
  # property :parent_id # Cannot be changed
  # property :config_path #todo

  property :current_user, virtual: true
  property :options

  # property :type

  # Validations
  collection :validations, populator: :validations! do
    property :id
    # property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
    # property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
    property :error_message
    # property :created_by_id, deserializer: -> (input, represented, *args) {represented.created_by_id = represented.contract_root.current_user.id}
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

  validation do
    params do
      required(:placeholder).filled
    end
  end

  # Computation


  property :compute_enabled
  property :compute_type_id
  property :compute_formula
  property :compute_lookup_entity_id

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
