class FormCondition < ApplicationRecord
  include UUIDHelper

  belongs_to :company
  belongs_to :form
  belongs_to :reference, polymorphic: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  has_many :rules, class_name: 'FormRule', as: :rule_parent
  has_many :actions, class_name: 'FormConditionAction'

  delegate :read_only?, :editable?, :visible?, :hidden?, :required?, :optional?, to: :condition_type
end
