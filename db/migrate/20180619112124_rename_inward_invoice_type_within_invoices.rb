class RenameInwardInvoiceTypeWithinInvoices < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoices, :inward_invoice_type_id, :invoice_type_id
  end
end
