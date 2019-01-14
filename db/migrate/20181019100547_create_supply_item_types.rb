class CreateSupplyItemTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :supply_item_types do |t|
      t.string :name
      t.text :description
      t.timestamps null: false
    end

    SupplyItemType.seed_data

    add_reference :inventory_line_items, :supply_item_type, index: true, foreign_key: true
  end
end
