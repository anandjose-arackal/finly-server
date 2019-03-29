class CreatePolicyLocationMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :policy_location_mappings do |t|
      t.integer :policy_id
      t.integer :location_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
