class AddTdsToOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :tds, :decimal, precision: 10, scale: 5
  end
end
