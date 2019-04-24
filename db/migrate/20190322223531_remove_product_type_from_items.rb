class RemoveProductTypeFromItems < ActiveRecord::Migration[5.2]
  def change
  	remove_column :items, :product_type, :integer
  end
end
