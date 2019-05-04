class AddCategoryCodeToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :category_code, :string, index: true
  end
end
