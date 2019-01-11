class CreateLevelReviewerMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :level_reviewer_mappings do |t|
      t.integer :level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.integer :reviewer_id, references: 'User', foreign_key: true, index: true
      t.decimal :threshold, precision: 20, scale: 5, default: 0
      t.boolean :exception, default: false

      t.timestamps null: false
    end
  end
end
