class ChangeActiveColumnInBudgets < ActiveRecord::Migration[5.2]
  def change
    change_column :budgets, :active, :boolean, default: true
    add_column :budget_groups, :active, :boolean, default: true
  end
end
