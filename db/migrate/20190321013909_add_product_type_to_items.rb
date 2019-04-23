class AddProductTypeToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :product_type, :integer, default: 1
    add_index :items, :product_type
  end
end
