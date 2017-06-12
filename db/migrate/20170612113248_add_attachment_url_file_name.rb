class AddAttachmentUrlFileName < ActiveRecord::Migration
  def change
    add_column :receipt_email_attachments, :attachment_url_file_name, :string
  end
end
