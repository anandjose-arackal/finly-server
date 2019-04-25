class RemovePurchaseOrderIdFromBankAccounts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :bank_accounts, :purchase_order_id, :integer
  end
end
