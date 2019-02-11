class AddUploaderToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_order_attachments, :uploader_id, :integer, references: "User", foreign_key: true, index: true
  end
end
