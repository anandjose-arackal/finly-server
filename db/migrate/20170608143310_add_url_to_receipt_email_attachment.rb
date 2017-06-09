class AddUrlToReceiptEmailAttachment < ActiveRecord::Migration
  def change
    add_column :receipt_email_attachments, :attachment_url, :text
    add_column :receipt_email_attachments, :attachment_url_file_name, :string
    add_reference :receipt_emails, :expense, index: true, foreign_key: true
    add_column :receipt_emails, :email_id, :string
    add_column :receipt_emails, :sender, :string
    add_column :receipt_emails, :source, :string
    add_column :receipt_emails, :timestamp, :datetime
  end
end
