class BudgetRuleExpenseTypeMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :expense_type
end
