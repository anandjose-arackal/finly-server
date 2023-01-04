class AddStateColumnsInInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :vendor_state_id, :integer
    add_column :invoices, :shipping_state_id, :integer
  end
end
