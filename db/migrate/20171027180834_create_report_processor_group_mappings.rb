class CreateReportProcessorGroupMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :report_processor_group_mappings do |t|
      t.integer :processor_group_id, references: 'ReportProcessorGroup', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :processor_accountable_id
      t.string :processor_accountable_type
      t.references :amount, index: true, foreign_key: true, null: false
      t.datetime :completed_at
      t.boolean :marked_as_completed, default: false
      t.integer :status_id, references: 'ReportProcessorGroupStatus', index: true, foreign_key: true, null: false
      t.references :payment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
