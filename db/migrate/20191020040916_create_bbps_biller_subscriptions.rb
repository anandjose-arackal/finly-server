class CreateBbpsBillerSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_biller_subscriptions do |t|
      t.references :bbps_biller, index: true, foreign_key: true, null: false
      t.string :name, index: true, null: false
      t.string :sequence_id, index: true, null: false
      t.text :customer_params
      t.integer :department_id, index: true, foreign_key: true, references: 'departments'
      t.integer :cost_center_id, index: true, foreign_key: true, references: 'cost_centers'
      t.integer :location_id, index: true, foreign_key: true, references: "branch_locations"
      t.integer :policy_id, index: true, foreign_key: true, references: 'policies'
      t.integer :created_by_user_id, index: true, foreign_key: true, references: 'users'
      t.datetime :deleted_at, index: true
      t.boolean :active, index: true, default: true
      t.text :note

      t.timestamps
    end
  end
end
