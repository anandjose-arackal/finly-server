class MigrateVendorAttachments < ActiveRecord::Migration[5.2]
  def change
    VendorAttachment.where(attachment_type: "pan_card").update_all(attachment_type: "pan")
    VendorAttachment.where(attachment_type: "").update_all(attachment_type: "others")
  end
end
