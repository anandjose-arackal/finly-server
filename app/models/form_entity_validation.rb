# == Schema Information
#
# Table name: form_entity_validations
#
#  id                :bigint           not null
#  uuid              :string(36)       not null, primary key
#  company_id        :bigint           not null
#  form_id           :string(255)      not null
#  error_message     :string(255)      not null
#  created_by_id     :integer
#  updated_by_id     :integer
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  validation_id     :string(255)
#  system_validation :boolean
#  internal          :boolean
#  is_updated        :boolean
#  can_be_updated    :boolean
#  rule              :text(65535)
#  form_entity_id    :string(255)      not null
#

class FormEntityValidation < ApplicationRecord
  include UUIDHelper, TemplateClonable

  belongs_to :company
  belongs_to :form
  belongs_to :form_entity
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  serialize :rule, Rules::Adapters::Store

  delegate :entity_path, to: :form_entity

  def self.system_validation(params = {}, &block)
    params[:system_validation] = false
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

  def rule(rule=NoObject)
    self.rule = rule unless rule == NoObject
    super()
  end

  # def rule(entity_path, predicate, value: nil, formula: nil, match_entity_path: nil)
  #   value = [value] if  value.present? and not value.respond_to?(:each)
  #
  #   rule_type_id = nil
  #   rule_type_id = FormRuleType.id_for(:value) if value.present?
  #   rule_type_id = FormRuleType.id_for(:formula) if formula.present?
  #   rule_type_id = FormRuleType.id_for(:entity) if match_entity_path.present?
  #
  #   rules.new(
  #       entity_path: entity_path,
  #       predicate: predicate,
  #       rule_type_id: rule_type_id,
  #       match_value: value,
  #       match_formula: formula,
  #       match_entity_path: match_entity_path
  #   )
  # end

  def reference(entity_path)
    template_reference[:entity_path] = entity_path
  end

  def error_message(error_message = NoObject)
    self.error_message = error_message unless error_message == NoObject
    super()
  end

  def as_json(options = {})
    case options[:json_format]
    when 'form_builder'
      rule = self.rule.as_store
    else
      rule = self.rule.as_store
    end
    form_entity.as_json(json_format: "form_reference").merge(
        {
            id: id,
            error_message: error_message,
            rule: rule,
        }
    )
  end

end
