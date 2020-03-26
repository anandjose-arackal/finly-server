class AddBudgetGroupToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :budget_group_id, :integer, references: "BudgetGroup", foreign_key: true, index: true
  end
end
