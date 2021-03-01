class AddMissingIndicesToVersions < ActiveRecord::Migration[6.0]
  def change
    add_index :versions, :user_transaction_id rescue nil
    add_index :versions, :created_at rescue nil
    add_index :versions, :deleted_at rescue nil
    add_index :versions, :item_type rescue nil
    add_index :versions, :item_id rescue nil
    add_index :versions, :event rescue nil
    add_index :versions, :whodunnit rescue nil
    add_index :versions, :transaction_id rescue nil
    add_index :versions, :user_ip rescue nil
    add_index :versions, :user_agent rescue nil
    add_index :versions, :item_subtype rescue nil
    add_index :versions, :company_id rescue nil
    add_index :versions, :created_by_id rescue nil
    add_index :versions, :document_number rescue nil
    add_index :versions, :parent_document_type rescue nil
  end
end
