class AddApprovedToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :approved, :boolean
    add_index :purchase_request_items, :approved
  end
end
