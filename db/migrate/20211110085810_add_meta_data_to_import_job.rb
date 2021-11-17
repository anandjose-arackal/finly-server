class AddMetaDataToImportJob < ActiveRecord::Migration[6.0]
  def change
    add_column :import_jobs, :meta_data, :text
  end
end
