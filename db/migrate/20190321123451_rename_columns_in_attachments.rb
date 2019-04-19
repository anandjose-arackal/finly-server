class RenameColumnsInAttachments < ActiveRecord::Migration[5.2]
  def change
    rename_column :attachments, :attachment_file_name, :file_file_name
    rename_column :attachments, :attachment_file_size, :file_file_size
    rename_column :attachments, :attachment_content_type, :file_content_type
    rename_column :attachments, :attachment_updated_at, :file_updated_at
  end
end
