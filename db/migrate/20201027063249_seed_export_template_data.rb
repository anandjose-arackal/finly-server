class SeedExportTemplateData < ActiveRecord::Migration[5.2]
  def change
    ExportTemplateNew.seed_data2
    ExportFormat.seed_data
    ExportResource.seed_data
  end
end
