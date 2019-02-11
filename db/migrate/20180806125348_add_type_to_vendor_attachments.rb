class AddTypeToVendorAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :vendor_attachments, :type, :string
  end
end
