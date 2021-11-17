class AddRequireAttachmentsToImportJob < ActiveRecord::Migration[6.0]
  def change
    add_column :import_jobs, :require_attachments, :boolean, default: false
  end
end
