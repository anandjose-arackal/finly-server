class AddGeneratedInvoiceNumberFlagToInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices,:generated_invoice_number, :boolean
  end
end
