class AddBankErrorMessageToYesBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_transactions, :bank_error_message, :text, limit: 4.megabytes - 1
  end
end
