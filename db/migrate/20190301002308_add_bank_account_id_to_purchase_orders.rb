class AddBankAccountIdToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :bank_account_id, :integer, references: 'BankAccount', foreign_key: true
    add_index :purchase_orders, :bank_account_id
  end
end
