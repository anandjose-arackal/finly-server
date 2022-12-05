class RenameDataToRecordInImportRecord < ActiveRecord::Migration[6.0]
  def change
    rename_column :import_records, :data, :record_data
  end
end
