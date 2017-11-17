class RenameForeignKeysForVendorAttachment < ActiveRecord::Migration
  def change
    rename_column :vendor_attachments, :vendor_id, :yes_bank_vendor_id
  end
end
