class RenameGeneratedInvoiceNumberInInvoices < ActiveRecord::Migration[4.2]
  def change
    rename_column :outward_invoices, :generated_invoice_number, :override_invoice_number
  end
end
