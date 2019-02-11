class ChangeEmailBodyToAttachment < ActiveRecord::Migration[4.2]
  def change
    remove_column :receipt_emails, :body
    remove_column :receipt_emails, :raw_text
    remove_column :receipt_emails, :raw_html
    remove_column :receipt_emails, :raw_headers

    add_attachment :receipt_emails, :body
    add_attachment :receipt_emails, :raw_text
    add_attachment :receipt_emails, :raw_html
    add_attachment :receipt_emails, :raw_header
  end
end
