class ChangeOutwardInvoiceDateToDate < ActiveRecord::Migration[4.2]
  def change
    rename_column :outward_invoices, :invoice_date, :date
    rename_column :outward_invoices, :invoice_due_date, :due_date
  end
end
