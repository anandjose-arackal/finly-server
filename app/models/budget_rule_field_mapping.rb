# == Schema Information
#
# Table name: budget_rule_field_mappings
#
#  id                      :integer          not null, primary key
#  budget_rule_id          :integer          not null
#  field_configuration_id  :integer          not null
#  field_drop_down_item_id :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class BudgetRuleFieldMapping < ApplicationRecord
  belongs_to :budget_rule, optional: true
  belongs_to :field_configuration, optional: true
  belongs_to :field_drop_down_item, optional: true

  scope :group_by_field_configuration, -> { group_by(&:field_configuration)}

end
