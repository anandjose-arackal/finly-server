class CreateApprovalRoutes < ActiveRecord::Migration[4.2]
  def change
    create_table :approval_routes do |t|
      t.references :purpose, index: true, foreign_key: true, null: false
      t.integer :level, null: false, index: true
      t.integer :reviewer_id, references: 'User', index: true, foreign_key: true, null: false
      t.integer :threshold, index: true, default: 0, null: false
      t.integer :created_by_user_id, references: 'User', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.references :policy, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
