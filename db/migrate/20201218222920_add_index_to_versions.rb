class AddIndexToVersions < ActiveRecord::Migration[6.0]
  def change
    add_index :versions, :company_id
    add_index :versions, [:company_id, :event, :parent_document_type], name: 'versions_event_company_id'
    add_index :versions, [:company_id, :user_transaction_id, :item_type, :parent_document_type], name: 'versions_index_company_item_type'
  end
end
