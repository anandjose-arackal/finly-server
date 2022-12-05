class AddFieldsToImportRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :import_records, :message, :string
    add_column :import_records, :internal_message, :string
    add_column :import_records, :trace, :text
    add_column :import_records, :status_id, :integer, references: "ImportRecordStatus", foreign_key: true, index: true

  end
end
