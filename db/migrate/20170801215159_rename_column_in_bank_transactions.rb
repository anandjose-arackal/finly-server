class RenameColumnInBankTransactions < ActiveRecord::Migration[4.2]
  def change
    rename_column :bank_transactions, :transfer_status, :transfer_status_id
  end
end
