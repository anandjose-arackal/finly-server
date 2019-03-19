class AddMoreFieldsToIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :unique_request_number, :string
    add_column :icici_bank_transactions, :utr, :string
  end
end
