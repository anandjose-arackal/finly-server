class AddNoteToExportFields < ActiveRecord::Migration[4.2]
  def change
    ExportField.seed_data
  end
end
