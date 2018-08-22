class ChangeTypeToAttachmentTypeInYesBankVendors < ActiveRecord::Migration
  def change
    rename_column :vendor_attachments, :type, :attachment_type
  end
end
