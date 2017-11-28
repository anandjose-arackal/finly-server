class RenameColumnTransactionInTrails < ActiveRecord::Migration
  def change
    rename_column :payment_receivable_transaction_trails, :transaction_id, :account_transaction_id
    rename_column :virtual_account_collect_trails, :transaction_id, :account_transaction_id
  end
end
