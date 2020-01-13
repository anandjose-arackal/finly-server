class AddIndexToItems < ActiveRecord::Migration[5.2]
  def change
    add_index :items, [:company_id, :active]
    add_index :items, [:supply_item_type_id,:product_type_id]
  end
end
