class AddTemplateInvoiceIdToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :template_invoice_id, :integer
    add_index :general_invoices, :template_invoice_id
  end
end
