class AddDateToOutwardInvoiceTrails < ActiveRecord::Migration
  def change
    add_column :outward_invoice_trails, :date, :date
  end
end
