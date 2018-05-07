class AddAdditionalInfoToInvoiceLineItems < ActiveRecord::Migration
  def change
    add_column :invoice_line_items, :item_info, :text
  end
end
