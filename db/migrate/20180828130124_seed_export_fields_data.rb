class SeedExportFieldsData < ActiveRecord::Migration
  def change
    ExportField.seed_data
  end
end
