class BudgetRuleCategoryMapping < ActiveRecord::Base
  belongs_to :budget_rule
  belongs_to :category
end
