class AddMoreAttributesToBudgetGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_groups, :period_id, :integer, references: "Period", foreign_key: true, index: true
    add_column :budget_groups, :purchase_order, :boolean
    add_column :budget_groups, :payment, :boolean
    add_column :budget_groups, :expense, :boolean
    add_column :budget_groups, :purchase_request, :boolean
    add_column :budget_groups, :invoice, :boolean
  end
end
