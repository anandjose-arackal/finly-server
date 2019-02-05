class BudgetRuleBranchLocationMapping < ApplicationRecord
  belongs_to :budget_rule
  belongs_to :branch_location
end
