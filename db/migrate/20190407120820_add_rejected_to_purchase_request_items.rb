class AddRejectedToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :rejected, :boolean
  end
end
