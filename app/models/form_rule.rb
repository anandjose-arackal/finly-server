class FormRule < ApplicationRecord
  belongs_to :company
  belongs_to :form
  belongs_to :rule_parent, polymorphic: true
  belongs_to :form_entity
  belongs_to :rule_type, class_name: "FormRuleType"
  belongs_to :match_entity, class_name: 'FormEntity', optional: true

  serialize :match_value, JSON

  delegate 'value?', 'entity?', 'formula?', to: :rule_type
end
