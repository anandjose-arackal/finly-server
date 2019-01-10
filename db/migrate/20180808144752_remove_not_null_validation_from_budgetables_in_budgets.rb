class RemoveNotNullValidationFromBudgetablesInBudgets < ActiveRecord::Migration[4.2]
  def change
    change_column :budgets, :budgetable_type, :string, null: true
    change_column :budgets, :budgetable_id, :integer,null: true
  end
end