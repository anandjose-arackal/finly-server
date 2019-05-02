class AddPoAdvanceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :po_advance, :integer, references: "Amount", foreign_key: true
    add_column :invoices, :po_prev_adjusted_advance, :integer, references: "Amount", foreign_key: true
    add_column :invoices, :po_adjusted_advance, :integer, references: "Amount", foreign_key: true
  end
end
