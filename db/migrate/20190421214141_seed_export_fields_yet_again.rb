class SeedExportFieldsYetAgain < ActiveRecord::Migration[5.2]
  def change
    ExportField.seed_data
  end
end
