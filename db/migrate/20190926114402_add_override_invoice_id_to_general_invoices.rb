class AddOverrideInvoiceIdToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :override_invoice_id, :string
  end
end
