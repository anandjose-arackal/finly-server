class RenameAncestryToParentId < ActiveRecord::Migration[5.2]
  def change
    rename_column :departments, :ancestry, :parent_id
    rename_column :categories, :ancestry, :parent_id
  end
end
