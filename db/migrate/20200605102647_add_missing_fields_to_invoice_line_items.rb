class AddMissingFieldsToInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :tds_percentage, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :tax_percentage, :decimal, :precision => 20, :scale => 5
    add_column :invoice_line_items, :item_number, :string
    add_column :invoice_line_items, :product_type_id, :string
    add_column :invoice_line_items, :gl_code, :string
  end
end
