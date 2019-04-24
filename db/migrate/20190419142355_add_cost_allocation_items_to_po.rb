class AddCostAllocationItemsToPo < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :cost_allocation_items, :boolean, default: false
  end
end
