class AddNetAmountToInvoiceItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :net_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
