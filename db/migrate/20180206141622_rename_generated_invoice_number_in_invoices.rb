class RenameGeneratedInvoiceNumberInInvoices < ActiveRecord::Migration
  def change
    rename_column :outward_invoices, :generated_invoice_number, :override_invoice_number
  end
end
