class CreateVendorAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_attachments do |t|
      t.attachment :attached_file
      t.text :description
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
