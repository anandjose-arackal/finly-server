class CreateReportProcessorGroupMappings < ActiveRecord::Migration
  def change
    create_table :report_processor_group_mappings do |t|
      t.integer :processor_group_id, references: 'ReportProcessorGroupMapping', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :processor_accountable_id, null: false
      t.string :processor_accountable_type, null: false
      t.references :amount, index: true, foreign_key: true, null: false
      t.datetime :completed_at
      t.integer :status_id, references: 'ReportProcessorGroupStatus', index: true, foreign_key: true, null: false
      t.references :payment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
