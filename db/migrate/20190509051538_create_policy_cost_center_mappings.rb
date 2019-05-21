class CreatePolicyCostCenterMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :policy_cost_center_mappings do |t|
      t.integer :cost_center_id
      t.integer :policy_id

      t.timestamps
    end
  end
end
