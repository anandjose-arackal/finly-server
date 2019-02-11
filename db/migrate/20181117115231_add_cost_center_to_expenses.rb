class AddCostCenterToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :cost_center_id, :integer, references: "CostCenter", foreign_key: true, index: true
  end
end
