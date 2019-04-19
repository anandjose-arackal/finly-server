class AddPurchaseOrderIdToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :purchase_order_id, :integer, references: 'PurchaseOrder', foreign_key: true
    add_index :quotations, :purchase_order_id
  end
end
