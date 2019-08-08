class AddCostAllocationItemsToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :cost_allocation_items, :boolean
  end
end
