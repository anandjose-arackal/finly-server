class ChangeFormatInPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_request_items, :quantity, :decimal, :precision => 20, :scale => 5
  end
end
