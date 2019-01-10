class AddNewFieldsToCardTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :mcc_code, :string
    add_column :card_transactions, :transaction_status, :string
    add_column :card_transactions, :api_reference_id, :string
  end
end
