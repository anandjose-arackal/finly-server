class AddResultFileToImportJob < ActiveRecord::Migration[6.0]
  def change
    add_attachment :import_jobs, :result_file
  end
end
