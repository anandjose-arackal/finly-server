class AddStateColumnsInInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :vendor_state_id, :integer
    add_column :purchase_orders, :vendor_state_id, :integer
    add_column :invoices, :billing_state_id, :integer
    add_column :purchase_orders, :billing_state_id, :integer
  end
end
