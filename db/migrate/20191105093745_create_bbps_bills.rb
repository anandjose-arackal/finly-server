class CreateBbpsBills < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_bills do |t|
      t.integer :subscription_id, references: 'BbpsBillerSubscription', foreign_key: true, index: true
      t.integer :user_id, references: 'User', foreign_key: true, index: true
      t.string :name

      t.string :sequence_id, index: true
      t.integer :department_id, references: 'Department', index: true, foreign_key: true
      t.integer :cost_center_id, references: 'CostCenter', index: true, foreign_key: true
      t.integer :location_id, references: 'BranchLocation', index: true, foreign_key: true
      t.integer :policy_id, references: 'Policy', index: true, foreign_key: true
      t.integer :controlling_level_id, references: 'ReviewalLevel', index: true, foreign_key: true

      t.integer :status_id, references: 'BbpsBillStatus', index: true, foreign_key: true
      t.integer :amount_id, references: 'Amount', index: true, foreign_key: true
      t.boolean :autofetched, index: true, default: false
      t.date :expected_due_date

      t.datetime :deleted_at
      t.timestamps
    end

    add_column :bbps_biller_subscriptions, :biller_category_name, :string, index: true
  end
end
