class AddBudgetGroupCriteriumToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :budget_group_criterium_id, :integer, references: "BudgetGroupCriterium", foreign_key: true, index: true
  end
end
