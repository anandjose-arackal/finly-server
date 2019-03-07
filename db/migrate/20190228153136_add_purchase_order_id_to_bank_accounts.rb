class AddPurchaseOrderIdToBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :purchase_order_id, :integer, references: "PurchaseOrder", foreign_key: true
    add_index :bank_accounts, :purchase_order_id
  end
end
