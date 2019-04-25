class AddCostCenterIdToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :cost_center_id, :integer
  end
end
