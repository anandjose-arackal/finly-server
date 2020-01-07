class AddDocumentAndRecordToExportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :document, :string, index: true
    add_reference :export_jobs, :record, polymorphic: true, index: true
    add_column :export_jobs, :crash_stacktrace, :text
    add_column :export_jobs, :message, :text
  end
end
