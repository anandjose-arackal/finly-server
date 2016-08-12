class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :name
      t.references :company, index: true, foreign_key: true
      t.integer :owner_id, :references => "User", index: true, foreign_key: true

      t.timestamps null: false
    end
    add_reference :user_manager_mappings, :policy, index: true, foreign_key: true
  end
end
