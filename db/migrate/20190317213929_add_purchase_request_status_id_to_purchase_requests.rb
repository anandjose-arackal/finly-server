class AddPurchaseRequestStatusIdToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :purchase_request_status_id, :integer, references: 'PurchaseRequestStatus', foreign_key: true
    add_index :purchase_requests, :purchase_request_status_id
  end
end
