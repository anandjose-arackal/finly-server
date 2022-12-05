class AddDocumentToImportRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :import_records, :document_id, :string
    add_column :import_records, :document_type, :string
    rename_column :import_records, :trace, :error_trace
  end
end
