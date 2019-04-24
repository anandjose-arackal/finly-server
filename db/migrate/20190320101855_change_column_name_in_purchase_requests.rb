class ChangeColumnNameInPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    rename_column :purchase_requests, :title, :description 
  end
end
