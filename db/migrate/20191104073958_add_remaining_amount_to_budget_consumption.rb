class AddRemainingAmountToBudgetConsumption < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_consumptions, :remaining_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
