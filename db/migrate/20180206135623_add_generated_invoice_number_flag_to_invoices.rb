class AddGeneratedInvoiceNumberFlagToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices,:generated_invoice_number, :boolean
  end
end
