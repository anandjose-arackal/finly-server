class AddTdsToOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :tds, :decimal, precision: 10, scale: 5
  end
end
