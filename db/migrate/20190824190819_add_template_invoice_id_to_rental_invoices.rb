class AddTemplateInvoiceIdToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :template_invoice_id, :integer
    add_index :rental_invoices, :template_invoice_id
  end
end
