class AddBudgetAmountToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_consumptions, :budget_amount_id, :integer, references: "Amount", index: true, foreign_key: true
  end
end
