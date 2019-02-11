class AddParentIdToInvoiceLineItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :parent_type, :string, polymorphic: true
    add_column :invoice_line_items, :parent_id, :string, polymorphic: true

    # Move all existing Invoice Line Items with parent Invoice to parent and parent type
    InvoiceLineItem.all.each do |item|
      parent_id = item.invoice_id
      invoice = Invoice.find parent_id
      item.update(parent: invoice)
    end
  end
end
