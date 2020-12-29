class SeedExportTemplateData < ActiveRecord::Migration[5.2]
  def change
    ExportFormat.seed_data
    ExportResource.seed_data
  end
end
