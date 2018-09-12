class SeedExportFieldsAgain < ActiveRecord::Migration
  def change
    ExportField.seed_data
  end
end
