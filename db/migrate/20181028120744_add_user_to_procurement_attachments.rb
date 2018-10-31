class AddUserToProcurementAttachments < ActiveRecord::Migration
  def change
    add_reference :procurement_attachments, :user, index: true, foreign_key: true
  end
end
