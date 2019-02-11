class FixTypoInDocumentItem < ActiveRecord::Migration[4.2]
  def change
    rename_column :document_items, :disount, :discount
    add_reference :document_items, :purchase_order_item, index: true, foreign_key: true
    add_column :document_items, :product_id, :string

  end
end
