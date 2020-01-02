class AddNoteToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :note, :text
  end
end
