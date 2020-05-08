class FormEntityValidation < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :form_entity
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :rules, class_name: 'FormRule', as: :rule_parent

  accepts_nested_attributes_for :rules

  def self.system_validation(params={}, &block)
    params[:custom] = false
    params[:internal] ||= false
    params[:is_updated] = false
    params[:can_be_updated] ||= false
    validation = self.new(params)
    validation.instance_eval &block if block_given?
    if validation.validation_id.blank?
      raise "Condition ID cannot be blank for #{validation.entity_path}"
    end
    validation
  end

  def rule(entity_path, predicate, value: nil, formula: nil, match_entity_path: nil)
    value = [value] if  value.present? and not value.respond_to?(:each)

    rule_type_id = nil
    rule_type_id = FormRuleType.id_for(:value) if value.present?
    rule_type_id = FormRuleType.id_for(:formula) if formula.present?
    rule_type_id = FormRuleType.id_for(:entity) if match_entity_path.present?

    rules.new(
        entity_path: entity_path,
        predicate: predicate,
        rule_type_id: rule_type_id,
        match_value: value,
        match_formula: formula,
        match_entity_path: match_entity_path
    )
  end

  def error_message(value=NoObject)
    self.error_message = value unless value == NoObject
    super()
  end

  def as_json(options={})
    {
        entity_path: entity_path,
        error_message: error_message,
        rules: rules
    }
  end

end
