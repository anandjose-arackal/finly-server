class AddAmountsToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :discounted_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :sgst_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :csgt_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :igst_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :tds_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
