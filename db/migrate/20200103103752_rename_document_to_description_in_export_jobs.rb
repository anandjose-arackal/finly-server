class RenameDocumentToDescriptionInExportJobs < ActiveRecord::Migration[5.2]
  def change
    rename_column :export_jobs, :document, :description
  end
end
