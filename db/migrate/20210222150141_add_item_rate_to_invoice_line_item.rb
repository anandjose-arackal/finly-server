class AddItemRateToInvoiceLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_line_items, :item_rate, :decimal, default: 0
  end
end
