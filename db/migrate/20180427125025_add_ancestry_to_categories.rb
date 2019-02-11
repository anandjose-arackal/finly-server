class AddAncestryToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :ancestry, :string
    add_index :categories, :ancestry
  end
end
