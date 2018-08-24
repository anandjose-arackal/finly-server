class AddAncestryToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :ancestry, :string
  end
end
