class RenameColumnInBankTransactions < ActiveRecord::Migration
  def change
    rename_column :bank_transactions, :transfer_status, :transfer_status_id
  end
end
