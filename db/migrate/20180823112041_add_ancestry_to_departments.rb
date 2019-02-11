class AddAncestryToDepartments < ActiveRecord::Migration[4.2]
  def change
    add_column :departments, :ancestry, :string
  end
end
