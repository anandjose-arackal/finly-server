class AddIndexToInwardDocumentItem < ActiveRecord::Migration[5.2]
  def change
    add_index :inward_document_items, [:purchase_order_item_id,:inventory_line_item_id], :name => "index_inward_item_po_item_item_id"
  end
end
