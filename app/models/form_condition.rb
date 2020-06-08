# == Schema Information
#
# Table name: form_conditions
#
#  id                :bigint           not null
#  uuid              :string(36)       not null, primary key
#  company_id        :bigint           not null
#  form_id           :string(255)      not null
#  created_by_id     :integer
#  updated_by_id     :integer
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  condition_id      :string(255)
#  custom            :boolean
#  internal          :boolean
#  is_updated        :boolean
#  can_be_updated    :boolean
#  rule              :text(65535)
#  referencable_id   :string(255)      not null
#  referencable_type :string(255)      not null
#

class FormCondition < ApplicationRecord
  include UUIDHelper, TemplateClonable

  belongs_to :company
  belongs_to :form
  belongs_to :referencable, polymorphic: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :actions, class_name: 'FormConditionAction'

  serialize :rule, Rules::Adapters::Store

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
    # self.reference_type = reference_type
    # self.reference_key = reference_key
    template_reference[:reference_key] = reference_key
    template_reference[:reference_type] = reference_type
  end

  def action(property, value)
    actions.new property: property, value: value
  end

  def rule(rule = NoObject)
    self.rule = rule unless rule == NoObject
    super()
  end

  def as_json(options = {})
    referencable.as_json(json_format: "form_reference").merge(
        {
            rule: rule.as_json_logic,
            actions: actions
        }
    )
  end

end
