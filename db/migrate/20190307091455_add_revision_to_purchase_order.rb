class AddRevisionToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :revised_po_id, :integer
    add_column :purchase_orders, :revision_of_id, :integer
    add_column :purchase_orders, :revision_number, :integer, default: 0

    add_index :purchase_orders, :revised_po_id
    add_index :purchase_orders, :revision_of_id
    add_index :purchase_orders, :revision_number
  end
end
