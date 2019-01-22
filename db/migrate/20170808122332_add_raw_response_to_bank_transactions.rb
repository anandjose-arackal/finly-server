class AddRawResponseToBankTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_transactions, :bank_response, :string
  end
end
