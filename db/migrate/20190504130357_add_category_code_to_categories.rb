class AddCategoryCodeToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :category_code, :string, index: true
    Purpose.seed_data
    Category.all.each {|cat| cat.save}
  end
end
