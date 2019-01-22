class CreateLevelUserReviewerMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :level_user_reviewer_mappings do |t|
      t.integer :level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.integer :user_id, references: 'User', foreign_key: true, index: true
      t.integer :reviewer_id, references: 'User', foreign_key: true, index: true
      t.integer :policy_id, references: 'Policy', foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
