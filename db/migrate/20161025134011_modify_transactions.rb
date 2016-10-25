class ModifyTransactions < ActiveRecord::Migration
  def change
    add_column :card_transactions, :reference_id, :string
    add_column :card_transactions, :auth_transaction_id, :string
    add_column :card_transactions, :transaction_mode, :string
    add_column :card_transactions, :itzcash_merchant_key, :string
    add_column :card_transactions, :merchant_city, :string
    add_column :card_transactions, :response_code, :string
    add_column :card_transactions, :serial_id, :string
    add_column :card_transactions, :product_code, :string

    remove_column :card_transactions, :channel
    remove_column :card_transactions, :bank_network
    remove_column :card_transactions, :card_currency_code
    remove_column :card_transactions, :network
    remove_column :card_transactions, :trace_number
    remove_column :card_transactions, :merchant_category_code
  end
end
