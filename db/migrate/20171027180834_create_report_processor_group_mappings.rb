class CreateReportProcessorGroupMappings < ActiveRecord::Migration
  def change
    create_table :report_processor_group_mappings do |t|
      t.integer :processor_group_id, references: 'ReportProcessorGroupMapping', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :account_id, null: false
      t.string :account_type, null: false
      t.references :amount, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
