class AddProformaToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :proforma_invoice_id, :integer
    add_column :invoices, :proforma_advance, :integer, references: 'Amount', foreign_key: true
    add_column :invoices, :total_proforma_advance, :integer
    add_index :invoices, :proforma_invoice_id
  end
end

