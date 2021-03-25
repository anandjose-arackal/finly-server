class AddTotalLineItemToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :total_line_item_discount_amount, :decimal, default: 0
  end
end
