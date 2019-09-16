class AddDepartmentCodeToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :code, :string
  end
end
