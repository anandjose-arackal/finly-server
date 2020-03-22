class AddTotalSpentAmountToBudgetConsumption < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_consumptions, :total_consumed_amount_id, :integer, references: "Amount", foreign_key: true, index: true rescue nil
  end
end
