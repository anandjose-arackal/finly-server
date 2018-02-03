class AddInvoiceNumberToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :invoice_number, :string
  end
end
