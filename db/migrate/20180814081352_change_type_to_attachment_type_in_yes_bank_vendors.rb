class ChangeTypeToAttachmentTypeInYesBankVendors < ActiveRecord::Migration[4.2]
  def change
    rename_column :vendor_attachments, :type, :attachment_type
  end
end
