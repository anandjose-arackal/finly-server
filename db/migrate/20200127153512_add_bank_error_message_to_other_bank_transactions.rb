class AddBankErrorMessageToOtherBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :bank_error_message, :text, limit: 4.megabytes - 1
    add_column :kotak_bank_transactions, :bank_error_message, :text, limit: 4.megabytes - 1
  end
end
