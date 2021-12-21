class AddReportingAdvanceField < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :reporting_po_advance, :decimal, precision: 20, scale: 10, default: 0
  end
end
