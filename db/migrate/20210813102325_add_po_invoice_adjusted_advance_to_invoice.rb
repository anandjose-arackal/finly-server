class AddPoInvoiceAdjustedAdvanceToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :po_invoice_adjusted_advance, :decimal, precision: 20, scale: 10, default: 0
  end
end
