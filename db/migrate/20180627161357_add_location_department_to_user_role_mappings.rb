class AddLocationDepartmentToUserRoleMappings < ActiveRecord::Migration[4.2]
  def change
    add_column :user_role_mappings, :company_department_id, :integer, references: 'CompanyDepartment', index: true, foreign_key: true
    add_column :user_role_mappings, :branch_location_id, :integer, references: 'BranchLocation', index: true, foreign_key: true
  end
end
