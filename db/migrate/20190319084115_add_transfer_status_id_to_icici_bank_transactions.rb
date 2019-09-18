class AddTransferStatusIdToIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :transfer_status_id, :integer, references: "BankTransferStatus", foreign_key: true, index: true
  end
end
