class RenameBankTransactionsTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :bank_transactions, :yes_bank_transactions
  end
end