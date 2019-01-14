class CreatePurchaseOrderItems < ActiveRecord::Migration[4.2]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, index: true, foreign_key: true
      t.references :inventory_line_item, index: true, foreign_key: true

      t.string :product_id
      t.string :description
      t.string :hsn_sac
      t.integer :quantity
      t.decimal :rate
      t.decimal :tax
      t.decimal :tds
      t.decimal :discount
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
