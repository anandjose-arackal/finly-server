class AddTaxableAmountToInvoiceLineItems < ActiveRecord::Migration
  def change
    add_column :invoice_line_items, :taxable_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end