class AddTdsDeductedToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_trails, :tds_value, :decimal, precision: 20, scale: 10, default: 0
  end
end
