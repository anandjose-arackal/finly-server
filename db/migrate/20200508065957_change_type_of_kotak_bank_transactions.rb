class ChangeTypeOfKotakBankTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :kotak_bank_transactions, :narration, :text
  end
end
