class AddInvoiceNumberToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :invoice_number, :string
  end
end
