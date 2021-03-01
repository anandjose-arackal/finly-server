class AddMissingIndicesToVersions < ActiveRecord::Migration[6.0]
  def change
    add_index :versions, :user_transaction_id
    add_index :versions, :created_at
    add_index :versions, :deleted_at
    add_index :versions, [:user_transaction_id, :created_at, :deleted_at], name: 'index_versions_on_id_created_deleted'
  end
end
