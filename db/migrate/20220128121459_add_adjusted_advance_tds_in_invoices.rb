class AddAdjustedAdvanceTdsInInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :adjusted_advance_tds, :decimal, precision: 20, scale: 10
  end
end
