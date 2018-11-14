class AddInvoiceIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_id, :string
  end
end
