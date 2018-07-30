class AddEntitiesForBudgetsInBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :purchase_order, :boolean
    add_column :budgets, :payment, :boolean
    add_column :budgets, :expense, :boolean
  end
end