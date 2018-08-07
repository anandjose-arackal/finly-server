class AddTypeToVendorAttachments < ActiveRecord::Migration
  def change
    add_column :vendor_attachments, :type, :string
  end
end
