class AddDetailsToKotakBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :kotak_bank_transactions, :bank_response, :text
    add_column :kotak_bank_transactions, :reversal_status_code, :string, index: true
    add_column :kotak_bank_transactions, :reversal_response, :text
    add_index :kotak_bank_transactions, :response_status_code
  end
end
