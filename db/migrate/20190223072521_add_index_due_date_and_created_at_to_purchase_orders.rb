class AddIndexDueDateAndCreatedAtToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
  	add_index :purchase_orders, [:due_date, :created_at]
  end
end
