class CreateReceiptEmailAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :receipt_email_attachments do |t|
      t.integer :receipt_email_id
      t.attachment :original_attachment

      t.timestamps null: false
    end
    add_index :receipt_email_attachments, :receipt_email_id
  end
end
