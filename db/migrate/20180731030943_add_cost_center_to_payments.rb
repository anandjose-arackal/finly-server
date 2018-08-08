class AddCostCenterToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :cost_center_id, :integer, references: "CostCenter", foreign_key: true, index: true
  end
end
