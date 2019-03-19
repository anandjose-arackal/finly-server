class AddRequestIdToIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :request_id, :string
  end
end
