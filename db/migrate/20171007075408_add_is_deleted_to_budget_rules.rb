class AddIsDeletedToBudgetRules < ActiveRecord::Migration
  def change
    add_column :budget_rules, :is_deleted, :boolean, default: false
    add_column :expense_rules, :is_deleted, :boolean, default: false
  end
end
