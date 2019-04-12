class RenameColumnInPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    rename_column :purchase_request_items, :delivery_date, :required_by_date
  end
end
