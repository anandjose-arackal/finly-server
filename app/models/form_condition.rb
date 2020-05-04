class FormCondition < ApplicationRecord
  belongs_to :company
  belongs_to :form
  belongs_to :reference, polymorphic: true
  belongs_to :condition_type, class_name: 'FormConditionType'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :rules, class_name: 'FormRule', as: :rule_parent

  delegate :read_only?, :editable?, :visible?, :hidden?, :required?, :optional?, to: :condition_type
end
