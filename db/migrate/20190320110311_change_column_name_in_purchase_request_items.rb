class ChangeColumnNameInPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :purchase_request_items, :inventory_line_item_id, :item_id
    rename_column :purchase_request_items, :unit_amount_id, :per_unit_estimated_amount_id
  end
end
