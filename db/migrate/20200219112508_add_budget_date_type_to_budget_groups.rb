class AddBudgetDateTypeToBudgetGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :budget_date_type_id, :integer, references: "BudgetDateType", foreign_key: true, index: true rescue nil
    add_column :budget_groups, :budget_date_type_id, :integer, references: "BudgetDateType", foreign_key: true, index: true rescue nil
  end
end
