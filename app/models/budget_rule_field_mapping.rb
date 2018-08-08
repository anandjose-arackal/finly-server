class BudgetRuleFieldMapping < ActiveRecord::Base
  belongs_to :budget_rule
  belongs_to :field_configuration
  belongs_to :field_drop_down_item

  scope :group_by_field_configuration, -> { group_by(&:field_configuration)}

end
