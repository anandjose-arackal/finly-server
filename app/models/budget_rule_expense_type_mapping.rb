# == Schema Information
#
# Table name: budget_rule_expense_type_mappings
#
#  id              :bigint(8)        not null, primary key
#  budget_rule_id  :integer          not null
#  expense_type_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class BudgetRuleExpenseTypeMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :expense_type
end
