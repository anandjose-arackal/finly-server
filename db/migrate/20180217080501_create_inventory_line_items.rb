class CreateInventoryLineItems < ActiveRecord::Migration[4.2]
  def change
    create_table :inventory_line_items do |t|
      t.decimal :tax, precision: 10, scale: 5
      t.decimal :discount, precision: 10, scale: 5
      t.string :hsn_sac
      t.references :company, index: true, foreign_key: true
      t.string :sku
      t.decimal :rate, precision: 10, scale: 5
      t.text :description
      t.references :category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
