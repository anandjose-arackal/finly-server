class AddUnbilledQuantityToInvoiceItem < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_line_items, :unbilled_quantity, :decimal, precision: 20, scale: 10, default: 0
  end
end
