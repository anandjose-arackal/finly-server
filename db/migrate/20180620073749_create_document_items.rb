class CreateDocumentItems < ActiveRecord::Migration[4.2]
  def change
    create_table :document_items do |t|

      t.references :parent_document, polymorphic: true, index: {name: 'indx_doc_items_on_parent_doc_type_and_parent_doc_id'}, null: false
      t.references :inventory_line_item, index: true, foreign_key: true

      t.string :description
      t.string :hsn_sac
      t.decimal :quantity, precision: 10, scale: 5
      t.decimal :rate, precision: 10, scale: 5
      t.decimal :tax, precision: 10, scale: 5, default: 0
      t.decimal :tds, precision: 10, scale: 5, default: 0
      t.decimal :disount, precision: 10, scale: 5, default: 0
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tds_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :discount_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :total_amount_id, references: "Amount", foreign_key: true, index: true
      t.date :delivery_date
      t.string :comment

      t.timestamps null: false
    end
  end
end
