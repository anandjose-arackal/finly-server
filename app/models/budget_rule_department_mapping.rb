class BudgetRuleDepartmentMapping < ApplicationRecord
  belongs_to :budget_rule, optional: true
  belongs_to :department, optional: true
end
