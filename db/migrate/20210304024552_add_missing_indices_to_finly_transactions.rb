class AddMissingIndicesToFinlyTransactions < ActiveRecord::Migration[6.0]
  def change
    add_index :finly_transactions, :deleted_at rescue nil
    add_index :finly_transactions, [:finly_account_type, :finly_account_id], name: :index_transactions_on_account rescue nil

    add_index :invoices, :agreement_item_id rescue nil
  end
end
