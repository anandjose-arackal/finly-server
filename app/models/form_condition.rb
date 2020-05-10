# == Schema Information
#
# Table name: form_conditions
#
#  id             :bigint           not null
#  uuid           :string(36)       not null, primary key
#  company_id     :bigint           not null
#  form_id        :string(255)      not null
#  reference_key  :string(255)      not null
#  reference_type :string(255)      not null
#  created_by_id  :integer
#  updated_by_id  :integer
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  condition_id   :string(255)
#  custom         :boolean
#  internal       :boolean
#  is_updated     :boolean
#  can_be_updated :boolean
#

class FormCondition < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  # belongs_to :reference, polymorphic: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :rules, class_name: 'FormRule', as: :rule_parent
  has_many :actions, class_name: 'FormConditionAction'

  def self.system_condition(params = {}, &block)
    params[:custom] = false
    params[:internal] ||= false
    params[:is_updated] = false
    params[:can_be_updated] ||= false
    condition = self.new(params)
    condition.instance_eval &block if block_given?
    if condition.condition_id.blank?
      raise "Condition ID cannot be blank for #{condition.entity_path}"
    end
    condition
  end

  def reference(reference_type, reference_key)
    self.reference_type = reference_type
    self.reference_key = reference_key
  end

  def action(property, value)
    actions.new property: property, value: value
  end

  def rule(entity_path, predicate, value: nil, formula: nil, match_entity_path: nil)
    value = [value] if value.present? and not value.respond_to?(:each)

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

  def as_json(options = {})
    {
        reference_type: reference_type,
        reference_key: reference_key,
        rules: rules,
        actions: actions
    }
  end

end
