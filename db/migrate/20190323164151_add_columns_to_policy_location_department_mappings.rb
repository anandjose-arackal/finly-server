class AddColumnsToPolicyLocationDepartmentMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_location_department_mappings, :company_id, :integer
    add_column :policy_location_department_mappings, :creator_id, :integer
  end
end
