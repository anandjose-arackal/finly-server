class AddDeletedAtToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :deleted_at, :datetime, index: true
    add_column :export_jobs, :master, :string, index: true
  end
end
