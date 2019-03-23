class AddProductTypeIdToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :product_type_id, :integer, default: 1, references: "ProductType", foreign_key: true
    add_index :items, :product_type_id
  end
end
