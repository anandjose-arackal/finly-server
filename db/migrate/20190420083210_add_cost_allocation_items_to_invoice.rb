class AddCostAllocationItemsToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :cost_allocation_items, :boolean, default: false
  end
end
