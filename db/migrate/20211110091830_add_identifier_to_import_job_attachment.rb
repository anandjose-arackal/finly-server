class AddIdentifierToImportJobAttachment < ActiveRecord::Migration[6.0]
  def change
    add_column :import_job_attachments, :identifier, :string
  end
end
