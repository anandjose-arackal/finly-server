class AddAttachmentToReceipts < ActiveRecord::Migration
  def change
    add_reference :receipts, :parent, index: true, polymorphic: true
  end
end
