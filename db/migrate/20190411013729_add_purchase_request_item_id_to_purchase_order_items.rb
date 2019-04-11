class AddPurchaseRequestItemIdToPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :purchase_request_item_id, :integer
  end
end
