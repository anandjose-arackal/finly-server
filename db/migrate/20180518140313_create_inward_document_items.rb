class CreateInwardDocumentItems < ActiveRecord::Migration[4.2]
  def change
    create_table :inward_document_items do |t|
      t.references :purchase_order_item, index: true, foreign_key: true
      t.references :inward_document, index: true, foreign_key: true
      t.references :inventory_line_item, index: true, foreign_key: true
      t.references :purchase_order_item, index: true, foreign_Key: true

      t.string :product_id
      t.string :description
      t.decimal :quantity
      t.decimal :delivered
      t.decimal :accepted
      t.decimal :rejected

      t.timestamps null: false
    end
  end
end
