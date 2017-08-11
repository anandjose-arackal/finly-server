class AddRawResponseToBankTransactions < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :bank_response, :string
  end
end
