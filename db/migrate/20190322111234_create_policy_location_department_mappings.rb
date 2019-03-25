class CreatePolicyLocationDepartmentMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :policy_location_department_mappings do |t|
      t.integer :location_id
      t.integer :department_id
      t.integer :policy_id

      t.timestamps
    end
  end
end
