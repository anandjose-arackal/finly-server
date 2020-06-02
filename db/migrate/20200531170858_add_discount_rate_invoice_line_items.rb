class AddDiscountRateInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_line_items, :discount_rate, :decimal
  end
end
