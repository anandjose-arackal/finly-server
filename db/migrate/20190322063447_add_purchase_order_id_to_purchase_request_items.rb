class AddPurchaseOrderIdToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :purchase_order_id, :integer
  end
end
