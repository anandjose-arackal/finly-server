class AddAdditionalInfoToInvoiceLineItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :item_info, :text
  end
end
