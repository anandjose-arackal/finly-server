class AddDateToOutwardInvoiceTrails < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoice_trails, :date, :date
  end
end
