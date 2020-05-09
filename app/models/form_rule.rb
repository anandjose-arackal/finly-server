# == Schema Information
#
# Table name: form_rules
#
#  id                :bigint           not null, primary key
#  company_id        :bigint           not null
#  form_id           :string(255)      not null
#  rule_parent_id    :string(255)      not null
#  rule_parent_type  :string(255)      not null
#  entity_path       :string(255)      not null
#  predicate         :string(255)      not null
#  rule_type_id      :integer          not null
#  match_value       :text(65535)
#  match_formula     :string(255)
#  match_entity_path :string(255)
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class FormRule < ApplicationRecord
  belongs_to :company
  belongs_to :form
  belongs_to :rule_parent, polymorphic: true
  # belongs_to :form_entity
  belongs_to :rule_type, class_name: "FormRuleType"
  # belongs_to :match_entity, class_name: 'FormEntity', optional: true

  serialize :match_value, JSON

  delegate 'value?', 'entity?', 'formula?', to: :rule_type

  def as_json(options={})
    {
        entity_path: entity_path,
        predicate: predicate,
        rule_type: rule_type.name,
        match_value: match_value,
        match_formula: match_formula,
        match_entity_path: match_entity_path
    }
  end
end
