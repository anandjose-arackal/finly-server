class RenameColumnTransactionInTrails < ActiveRecord::Migration
  def change
    remove_column :payment_receivable_transaction_trails, :transaction_id
    add_column :payment_receivable_transaction_trails, :account_transaction_id, :integer, references: "VirtualAccountTransaction", foreign_key: true
    # rename_column :virtual_account_collect_trails, :transaction_id, :account_transaction_id
    add_column :virtual_account_collect_trails, :account_transaction_id, :integer, references: "VirtualAccountTransaction", foreign_key: true
  end
end
