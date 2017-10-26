class CreateReportProcessorGroups < ActiveRecord::Migration
  def change
    create_table :report_processor_groups do |t|
      t.boolean :is_completed, default: false
      t.boolean :is_deleted, default: false
      t.datetime :completed_at
      t.integer :total_amount_id, references: 'Amount', null: false, foreign_key: true, index: true
      t.integer :processed_amount_id, references: 'Amount', null: false, foreign_key: true, index: true
      t.integer :created_by_user_id, references: 'User', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
