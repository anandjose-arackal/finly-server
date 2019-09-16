class AddDetailsToKotakBankTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :kotak_bank_transactions, :reversal_api_counter, :integer, default: 0
  end
end
