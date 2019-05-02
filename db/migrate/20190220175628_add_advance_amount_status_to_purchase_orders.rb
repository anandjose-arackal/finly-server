class AddAdvanceAmountStatusToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :advance_amount_status_id, :integer, references: "AdvanceAmountStatus", foreign_key: true
  	add_index :purchase_orders, :advance_amount_status_id
  end
end
