class AddOverrideInvoiceIdToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :override_invoice_id, :string
  end
end
