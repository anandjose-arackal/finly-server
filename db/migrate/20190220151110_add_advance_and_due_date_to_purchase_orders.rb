class AddAdvanceAndDueDateToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :advance_amount_id, :integer, references: "Amount", foreign_key: true
    add_column :purchase_orders, :due_date, :date
    add_index :purchase_orders, :advance_amount_id
  end
end
