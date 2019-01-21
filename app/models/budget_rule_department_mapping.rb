class BudgetRuleDepartmentMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :department
end
