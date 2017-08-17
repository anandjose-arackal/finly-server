class AddNoteToExportFields < ActiveRecord::Migration
  def change
    ExportField.seed_data
  end
end
