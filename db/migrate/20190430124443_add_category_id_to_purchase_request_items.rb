class AddCategoryIdToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :category_id, :integer, references: 'Category', foreign_key: true
    add_index :purchase_request_items, :category_id
  end
end
