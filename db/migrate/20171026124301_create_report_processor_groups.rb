class CreateReportProcessorGroups < ActiveRecord::Migration
  def change
    create_table :report_processor_group_statuses do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    ReportProcessorGroupStatus.seed_data
    create_table :report_processor_groups do |t|
      t.integer :status_id, references: 'ReportProcessorGroupStatus', index: true, foreign_key: true, null: false
      t.boolean :is_deleted, default: false
      t.boolean :payment_file_generated, default: false
      t.datetime :payment_file_generated_at, default: false
      t.datetime :completed_at
      t.integer :total_amount_id, references: 'Amount', null: false, foreign_key: true, index: true
      t.integer :processed_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :created_by_user_id, references: 'User', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
