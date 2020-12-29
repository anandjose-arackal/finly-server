class AddUserTransactionIdToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :user_transaction_id, :string, null: true
  end
end
