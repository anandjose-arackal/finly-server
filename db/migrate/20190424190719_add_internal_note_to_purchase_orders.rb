class AddInternalNoteToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :internal_note, :text
  end
end
