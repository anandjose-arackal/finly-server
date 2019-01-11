class RenameCategoriesToCategory < ActiveRecord::Migration[4.2]
  def change
    rename_column :quickbooks_categories, :categories_id, :category_id
  end
end
