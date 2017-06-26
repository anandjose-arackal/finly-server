class RenameCategoriesToCategory < ActiveRecord::Migration
  def change
    rename_column :quickbooks_categories, :categories_id, :category_id
  end
end
